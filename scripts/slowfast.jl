#Script for slow fast examination of time delays

include("packages.jl")

#Non-dimensionalized
@with_kw mutable struct RozMacPar
    r = 2.0
    k = 3.0
    a = 1.1
    h = 0.8
    e = 0.7
    m = 0.4
    σ = 0.1
    ε = 0.1
end

par_rozmac = RozMacPar()

function roz_mac_II!(du, u, p, t,)
    @unpack r, K, a, h, e, m = p
    R, C = u
    du[1] = r * R * (1 - R / K) - a * R * C / (1 + a * h * R)
    du[2] = ε ( e * a * R * C / (1 + a * h * R) - m * C )
    return
end

function roz_mac_II(u, par)
    du = similar(u)
    roz_mac_II!(du, u, par, 0.0)
    return du
end

# Find equilibria - should be same as normal but also with ε = 0
x, y, r, k, a, m, e, h = symbols("x, y, r, k, a, m, e, h", real = true)

f(x, y) = r * x * (1 - x / k) - a * x * y / (1 + a * h * x)
g(x ,y) = e * a * x * y / (1 + a * h * x) - m * y

SymPy.solve(f(x,y),x)
SymPy.solve(f(x,y),y)
SymPy.solve(g(x,y),x)
SymPy.solve(g(x,y),y)
# Plot isoclines and vector fields
using PyPlot

function roz_mac_res(R, C, p)
    @unpack r, k, h, a, m = p
    return r * R * (1 - R / k) - (a * R * C / (1 + a * h * R) )
end

function roz_mac_con(R, C, eff, ep, p)
    @unpack h, a, m = p
    return ep * ( ( eff * a * R * C ) / (1 + a * h * R) - m * C )
end

function con_iso(eff, p)
    @unpack m, a, h = p
    m / (a * (eff - h * m))
end

function res_iso(R, p)
    @unpack a, k, r, h = p
    r * (a * h * k * R - a * h * R^2 + k - R) / (a * k)
end

function roz_mac_plot(eff, ep)
    minval = 0
    maxval = 3
    steps = 100
    resconrange = range(minval,stop=maxval,length=steps)

    U = [roz_mac_res(R, C, par_rozmac) for C in resconrange, R in resconrange]
    V = [roz_mac_con(R, C, eff, ep, par_rozmac) for C in resconrange, R in resconrange]
    speed = sqrt.(U.^2 .+ V.^2)
    lw = 5 .* speed ./ maximum(speed) # Line Widths
    streamplot(collect(resconrange), collect(resconrange), U, V, density = 0.6, color = "k", linewidth = lw)
    PyPlot.plot(collect(resconrange), [res_iso(R, par_rozmac) for R in resconrange])
    return PyPlot.plot(repeat([con_iso(eff, par_rozmac)],100),collect(resconrange))
end

# - Before hopf fixed point
let
    figure()
    subplot(211)
    roz_mac_plot(0.45, 1)
    subplot(212)
    roz_mac_plot(0.45, 0.1)
    gcf()
end
# - Before hopf damped oscillations
let
    figure()
    subplot(211)
    roz_mac_plot(0.6, 1)
    subplot(212)
    roz_mac_plot(0.6, 0.1)
    gcf()
end
# - At hopf
let
    figure()
    subplot(211)
    roz_mac_plot(0.73, 1) #need to differentiate and find max
    subplot(212)
    roz_mac_plot(0.73, 0.1)
    gcf()
end
# - After hopf (limit cycle)
let
    figure()
    subplot(211)
    roz_mac_plot(0.9, 1)
    subplot(212)
    roz_mac_plot(0.9, 0.1)
    gcf()
end

## Dimensionalized
#Setup
@with_kw mutable struct RozMacPar
    r = 2.0
    K = 3.0
    a = 1.1
    h = 0.8
    e = 0.7
    m = 0.4
    σ = 0.1
end

function roz_mac_II!(du, u, p, t,)
    @unpack r, K, a, h, e, m = p
    R, C = u
    du[1] = r * R * (1 - R / K) - a * R * C / (1 + a * h * R)
    du[2] = e * a * R * C / (1 + a * h * R) - m * C
    return
end

# Find equilibria - should be same as normal but also with ε = 0

# Find isoclines

# Create vector fields
# - Before hopf fixed point

# - Before hopf damped oscillations

# - At hopf

# - After hopf (limit cycle)
