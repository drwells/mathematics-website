---
title: Quasi-Geostrophic Equations
category: research
---

Quasi-Geostrophic Equations
===========================
<center>
<video controls>
<source src="../qge1.webm" type="video/webm">
</video>
</center>

Numerical solution of the QGEs with a pseudospectral method on a \\(257 \times
513\\) grid corresponding to \\([0, 1] \times [0, 2]\\). The colors red and blue
correspond to clockwise and counterclockwise rotation (or positive and negative
vorticity) of the fluid respectively. The instantaneous vorticity is on the left
and the average vorticity is on the right. The four gyre average is a classic
result. I used \\(Re = 450\\), \\(Ro = 0.0036\\), and \\(F = \sin(\pi (y -
1))\\).


The Quasi-Geostrophic Equations are a simple model of planet-scale fluid
flows. The usual formulation is

$$
\begin{equation}
J(q,\psi) - \dfrac{1}{Re} \Delta q = f , \, q = Ro \Delta \psi + y
\end{equation}
$$

where \\(Re\\) and \\(Ro\\) are the Reynolds and Rossby numbers and \\(J\\) is
the determinant of the Jacobi matrix:

$$
\begin{equation}
J(u,v) = \dfrac{\partial u}{\partial x}\dfrac{\partial v}{\partial y} -
\dfrac{\partial u}{\partial y}\dfrac{\partial v}{\partial x}.
\end{equation}
$$

This formulation uses the *streamfunction vorticity* approach, where instead
of solving for the velocity we find a function \\( \psi \\) such that

$$
\begin{equation}
v_{x} = -\dfrac{d\psi}{dy}, v_{y} = \dfrac{d\psi}{dx}
\end{equation}
$$

which automatically satisfies incompressibility. Similarly, vorticity is
defined as \\( \omega := \nabla \times v \\). The two are closely related as the
Laplacian of the streamfunction is just the vorticity.

This pair of equations closely resemble the two-dimensional Navier Stokes
equations and techniques that work for one equation tend to work well for the
other.

Pseudospectral Methods
----------------------
Pseudospectral methods combine high accuracy and efficient algorithms. The main
drawback is that they only work on hypercubes or things that can be contorted
into hypercubes. This makes them great at some things, like examining the
scales of motion in a fluid flow.

The movie at the top of this page was generated with a double sine expansion;
that is

$$
\begin{equation}
\omega(t, x, y) = \sum_{j = 1}^{513} \sum_{i = 1}^{257} c_{i j}(t)
\sin(i \pi x) \sin(j \pi y/2).
\end{equation}
$$

The DST-1 (or, in FFTW, RODFT00) enables fast evaluation of derivatives.

\\( C^1 \\) Finite Element Spaces
---------------------------------
One way to simplify the QGE is by getting rid of the potential vorticity
term. Substituting in yields a scalar equation of just the streamfunction:

$$
\begin{equation}
\dfrac{1}{Re} \Delta^2 \psi + J(\Delta \psi, \psi) - \dfrac{1}{Ro}
\dfrac{\partial \psi}{\partial x} = \dfrac{1}{Ro} f
\end{equation}
$$

The equation now resembles a nonlinear transport equation with a
hyper-diffusion term, a nonlinear term, and a destabilizing convective term
(the lone \\(x\\) derivative is the final form of the coriolis force which
tends to create boundary layers). This reduction to a single scalar quantity
makes the equation more suitable for Petrov-Galerkin type stabilization
methods. Additionally, it is easier (at least I found it so!) to prove
optimality of error estimates with the quasigeostrophic equation in this form.

Reduction to one variable comes with a price; the biharmonic (\\(\Delta^2
\psi\\)) term requires high-order finite elements. Our group opted to use the
Argyris-5 (sometimes known as TUBA-21) 5th-degree finite element with 21
degrees of freedom, which has continuous derivatives (and hence a jump
discontinuity in the second derivative, meaning that the weak form of the
discretized biharmonic operator is 'nice').
