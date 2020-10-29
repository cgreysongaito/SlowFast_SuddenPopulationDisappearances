include("packages.jl")

include("slowfast_commoncode.jl")


#Maximum value of resource isocline
0.9318181818181819
# Time series and phase plots of stochastic canards
let
    test = figure()
    pert_timeseries_plot(0.01, 0.6, 0.0, 1, 1234, 10000.0, 2000.0:100.0:10000.0)
    return test
end

let
    test = figure()
    pert_phase_plot(0.01, 0.7, 0.0, 1, 1234, 5000.0, 2000.0:1.0:5000.0)
    vlines(0.9318181818181819, ymin = 2.1, ymax = 2.4, linestyles = `dashed`)
    return test
end


#Examination of what sto solver spits out
test = RozMac_pert(0.01, 0.6, 0.0, 1, 1234, 5000.0, 2000.0:1.0:5000.0)



# Idea 1 return map taking both vector of deterministic and vector or noise (only in C direction)nmbvcy
function orientation(p1, p2, p3)
    val = (p2[2] - p1[2]) * (p3[1] - p2[1]) - (p3[2] - p2[2]) * (p2[1] - p1[1])
    if (val == 0)
        return 0 #colinear
    elseif (val > 0)
        return 1 #clockwise
    else
        return -1 #anticlockwise
    end
end

function dointersect(p1, p2, q1, q2) # https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/
    o1 = orientation(p1, p2, q1)
    o2 = orientation(p1, p2, q2)
    o3 = orientation(q1, q2, p1)
    o4 = orientation(q1, q2, p2)

    if (o1 != o2 && o3 != o4)
        return true
    else
        return false
    end
end

function cf_returnmap(ep, eff, mean, freq, seed, tsend, tvals)
    sol = RozMac_pert(ep, eff, mean, freq, seed, tsend, tvals)
    rm_point1 = [0.9318181818181819, 2.1] #NOTE THIS ONLY WORKS IF DON"T CHANGE a or k #TODO need to code in more general method - ie calculating max resisocline then adding error
    rm_point2 = [0.9318181818181819, 2.4]#NOTE THIS ONLY WORKS IF DON"T CHANGE a or k
    rm_pass_points = []
    rm2_pass_points = []
    count = 0
    for i in 1:length(sol)-1
        if sol.u[i+1][1] < 0.9318181818181819 && sol.u[i][1] > 0.9318181818181819
            if dointersect(sol.u[i],sol.u[i+1],rm_point1,rm_point2) == true #Stricter condition for intersection of return map
                append!(rm_pass_points, [[i , sol.u[i][1], sol.u[i][2]]])
            end
        end
    end

    for j in 1:length(rm_pass_points)
        for l in Int64(rm_pass_points[j][1]):length(sol)-1
            if sol.u[l+1][1] < 0.9318181818181819
                if 0 < sol.u[l][1] < 0.1 && 2.1 < sol.u[l][2] < 2.4
                    append!(rm2_pass_points, [rm_pass_points[j]])
                    break
                end
            else
                break
            end
        end
    end
    for j in 1:length(rm2_pass_points)
        for l in Int64(rm2_pass_points[j][1]):length(sol)-1
            if sol.u[l+1][1] < 0.9318181818181819 && sol.u[l][1] > 0.9318181818181819
                if dointersect(sol.u[l],sol.u[l+1],rm_point1,rm_point2) == true #Stricter condition for intersection of return map
                    count +=1
                end
            end
        end
    end

    if count > 0
        return true
    else
        return false
    end
end


#TODO what about if we don't get full canard but start of canard then won't get second  intersection
cf_returnmap(0.01, 0.7, 0.0, 1, 1234, 5000.0, 2000.0:1.0:5000.0)
#Idea size of resource vector - decrease from maximum to 0 axis and increase from zero to some point
# dot product of two othogonal vectors is equal to 0
function magnitude(vec)
    return sqrt(vec[1]^2 + vec[2]^2)
end

function cf_othogvectors(ep, eff, mean, freq, seed, tsend, tvals)
    sol = RozMac_pert(ep, eff, mean, freq, seed, tsend, tvals)
    # count = 0
    angledata = fill(0.0, length(sol)-1)
    for i in 1:length(sol)-2
        vector1 = [sol.u[i+1][1]-sol.u[i][1], sol.t[i+1]-sol.t[i]]
        vector2 = [sol.u[i+2][1]-sol.u[i+1][1], sol.t[i+2]-sol.t[i+1]]
        check = dot(vector1,vector2) / ( magnitude(vector1) * magnitude(vector2) )
        if check > 1
        angledata[i] = rad2deg(acos(round(check;digits = 4)) )
        else
        angledata[i] = rad2deg(acos(check))
        end
        # if 50 < angle < 100
        #     count += 1
        # end
    end
    return angledata
end


#angle data does show spikes for each canard so vector angle method is finding canards BUT probably dependent on peturbation frequency - need to make generalizable
vectors = cf_othogvectors(0.01, 0.6, 0.0, 1, 1234, 10000.0, 2000.0:1.0:10000.0)

let
    test = figure()
    plot(collect(2000.0:1.0:9999.0), vectors)
    return test
end
#Problem - after 16 decimal places sqrt rounds up

v1 = [-1.2900372381423753e-7, 1.0]
v2 = [-1.0658821740539145e-7, 1.0]

v1 = vectors[1]
v2 = vectors[2]
rad2deg(acos(dot(v1,v2) / ( magnitude(v1) * magnitude(v2) )))
( magnitude(v1) * magnitude(v2) )
dot(v1,v2)
dot(v1,v2)/( magnitude(v1) * magnitude(v2) )
magnitude(v1)
magnitude(v2)
v1[1]*v2[1]
v1[1]^2

magnitude(v1)
v1[1]^2 +1
sqrt(v1[1]^2 +1)
# examine heat map of stochastic realization should be over certain colour
erer
