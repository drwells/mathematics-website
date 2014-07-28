---
title: Centered Trajectory
category: tutorial
---

Centering the Flow in Model Reduction
=====================================

It is fairly common in model reduction to 'center' the data; that is, subtract
the average of the dataset and construct a reduced-order model from only the
changing parts of the dataset. The usual argument is that the first POD vector
will roughly correspond to the mean. Therefore the first singular value will be
several orders of magnitude larger than the following singular values, which
makes calculating accurate POD vectors more difficult. Furthermore, the mean
should not change in time, so not permitting this can make POD-ROMs more
stable. It is worth noting that (as always, with model reduction) this is
problem dependent: I do not doubt that examples exist where this is decreases
accuracy or is worthless. However, it does seem to work well for fluid
problems. For example, consider a linear PDE with solution
\\(u = u_c + \bar{u}\\)
$$
\begin{equation}
    (u_c + \bar{u})_t = L (u_c + \bar{u}) + F(t)
\end{equation}
$$

so, as the mean does not depend on time and \\(L\\) is linear,

$$
\begin{equation}
    (u_c)_t = L u_c + L \bar{u} + F(t) \\
            = L u_c + F_2(t)
\end{equation}
$$

where we lump the contribution of \\(L \bar{u}\\) (a constant) with the load
vector. Since we are interested in numerical approximation by Galerkin methods,
the next step is to get the weak form:

$$
\begin{equation}
    (u_{ct}, v) = B(u_c, v) + (F_2(t), v)
\end{equation}
$$

where \\(B\\) is the appropriate bilinear form and \\((\cdot, \cdot)\\) is the
\\(L^2\\) inner product. Now we approximate \\(u_c\\) by

$$
\begin{equation}
    u_c \approx u_r = \sum a_j(t) \varphi_j(x)
\end{equation}
$$

where \\(\varphi_j(x)\\) is a POD basis function. Hence we have a
semi-discretization

$$
\begin{equation}
    (u_{rt}, \varphi_j) = B(u_r, \varphi_j) + (F_2(t), \varphi_j).
\end{equation}
$$

We can rewrite this in matrix form:

$$
\begin{equation}
    M_r \dot{a} = \hat{B}_r a + \Phi^T \hat{F}_2(t)
\end{equation}
$$

where
$$
\begin{equation}
    \hat{F}_2(t) = \hat{B} \hat{\bar{u}} + \hat{F}(t).
\end{equation}
$$

Here \\(\hat{F}(t)\\) is the load vector and \\(\hat{B}\\) is the matrix
discretization of the bilinear form \\(B\\), both from the underlying finite
element model, and \\(\hat{\bar{u}}\\) is the finite element approximation of
the mean.

\\(\Phi\\) is the (large) matrix where the \\(j\\)th column is the finite
element basis function coefficients of \\(\varphi_j\\). Additionally,
\\(M_r\\) is the mass matrix of the POD system and \\(\hat{B}_r\\) is the
discrete form of the bilinear form \\(B\\) in the POD system.

A simple ODE algorithm is the \\(\theta\\) method, which yields the fully
discrete system

$$
\begin{equation}
    M_r a_{n + 1} = M_r a_n
    + k \left(\theta \hat{B}_r a_n + (1 - \theta) \hat{B}_r a_{n + 1} \\
    + \Phi^T \left(\theta \hat{F}_2(t_n)
    + (1 - \theta) \hat{F}_2(t_{n + 1})\right)\right)
\end{equation}
$$

where \\(k\\) is the time step. Finally, note that if this is an autonomous
system, this simplifies very nicely:

$$
\begin{equation}
    M_r a_{n + 1} = M_r a_n
    + k \left(\theta \hat{B}_r a_n + (1 - \theta) \hat{B}_r a_{n + 1}
    + \Phi^T \hat{F}_2\right).
\end{equation}
$$
