---
title: Pseudospectral Methods
category: research
---

Pseudospectral Methods
======================
<img src="../highresqge.png" alt="High resolution pseudospectral approximation.">
High-resolution pseudospectral approximation of the QGE: \\(t = 0.6531\\), \\(Re =
1000\\), \\(Ro = 0.00025\\), and \\(F = \sin(\pi(y - 0.5))\\).

Overview
--------
There is a fair amount of overlap here with the page on the QGEs. Pseudospectral
methods approximate solutions to PDEs as linear combiations of some global,
orthogonal basis. For example, we can approximate the vorticity in the QGEs as

$$
\begin{equation}
\omega(t, x, y) = \sum_{j = 1}^{N} \sum_{i = 1}^{m} c_{i j}(t)
\sin(i \pi x) \sin(j \pi y).
\end{equation}
$$

on a unit square. This allows for very fast time stepping: evaluating the
"right-hand side" of the resulting ODE system is done in \\(n \log(n)\\) time by
the fast Fourier transform. For example, to evaluate the
streamfunction-vorticity nonlinearity in either 2D Navier Stokes or the QGE:

    #!python
    streamfunction_hat = laplacian_inverse_hat*vorticity_hat
    streamfunction_hat *= -1

    streamfunction_x = self.spectral_expansion.get_derivative(
        streamfunction_hat, 0, frequency_input=True)
    streamfunction_y = self.spectral_expansion.get_derivative(
        streamfunction_hat, 1, frequency_input=True)
    vorticity_x = self.spectral_expansion.get_derivative(
        vorticity_hat, 0, frequency_input=True)
    vorticity_y = self.spectral_expansion.get_derivative(
        vorticity_hat, 1, frequency_input=True)

    convection = np.empty_like(vorticity_x)
    numexpr.evaluate("streamfunction_x*vorticity_y"
                     " - streamfunction_y*vorticity_x"
                     " + rossby_inv*streamfunction_x",
                     out=convection)
    convection_hat = self.spectral_expansion.get_frequency(convection)

Note that solving the Poisson sub-problem is just one vector-vector multiply
(linear time). Calculating each derivative requires two transforms (one discrete
sine and one discrete cosine). We do not need to assemble any matrices or
perform any matrix-vector multiplies. This treatment of the nonlinearity is
where the "pseudo" comes from: Instead of evaluating the convolution in the
frequency domain, we have mapped back to the physical domain. I later dealias
the resulting solution.

The main downside to this speedy formulation is that I cannot use implicit
methods and have serious time step constraints. For my application
(high-resolution geophysical flows) the timestep is even more constrained by
accuracy requirements so this is happily not an issue.

I am interested in both theoretical (error and convergence analysis) and
practical issues in pseudospectral methods.

Scientific Computing Issues
---------------------------
There are a number of interesting issues that come up in practice that are not
well documented in the literature. By Amdahl's law, it is better to calculate
the first derivatives concurrently with one processor per transform than to
calculate them in serial with four processors per transform. I am interested in
using message queueing/passing systems (MPI or 0MQ) to exploit this parallelism.

Another interesting problem is how to add and multiply the arrays in an
effective manner. This problem appears trivial but is actually rather deep and
draws upon ideas in computer architecture. We wish to combine four arrays and
one scalar to calculate the convective term. The naive algorithm is (more or
less)

1. Calculate the first product \\(a := \psi_x \omega_y\\).
2. Calculate the second product \\(b := \psi_y \omega_x\\).
3. Calculate the third product \\(c := Ro^{-1} \psi_x \\).
4. Calculate the first sum \\(d := a - b\\).
5. Calculate the final answer \\(e := c + d\\).

This involves loading data into and out of the processor caches five times,
which is rather slow. This is what Python will do by default (more or less). The
library I used above (numexpr) gets around this issue by carefully buffering
small chunks of all four arrays into the cache *once* and writing the result to
RAM *once* to greatly speed things up. I saw a speedup of 140x due to better
cache management with a Runge-Kutta algorithm right after I started using
numexpr.

Infinite Ocean Problems
-----------------------
While rectangular oceans are not particularly realistic, enforcing boundary
conditions is useful for examining the interplay between the western boundary
layer caused by the coriolis effect (low Rossby number) and the internal
boundary layers caused by inertial forces (high Reynolds number). In another
class of problems, we consider the ocean to be infinite and use periodic
boundary conditions and look for solutions of the form

$$
\begin{equation}
    u(t, x, y, z) = \sum_{j = 1}^{N} \sum_{k = 1}^{N} \sum_{l = 1}^{M}
    c_{ijk}(t) \exp(i \pi (j x + k y)) T_l(z)
\end{equation}
$$

where \\(T_l(z)\\) is a Chebyshev polynomial.
