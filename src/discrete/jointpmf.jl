
#################################################
#
#   Type definitions and properties
#
#################################################

"""
Joint finite distribution represented by probability mass function.
"""
mutable struct JointPMF{T<:AbstractFloat}
    varlist::VarList{DVar{0}}
    p::Array{T}

    function JointPMF{T}(vl::VarList{DVar{0}}, p::Array{T}) where T<:AbstractFloat
        nv = length(vl)
        ndims(p) == nv ||
            throw(DimensionMismatch(
                "ndims(p) does not match the number of variables."))
        for i = 1:nv
            size(p,i) == length(vl[i].space) ||
                throw(DimensionMismatch(
                    "size(p,i) does not match the corresponding space size."))
        end
        new(vl, p)
    end
end

JointPMF{T<:AbstractFloat}(vl::VarList{DVar{0}}, p::Array{T}) = JointPMF{T}(vl, p)

function JointPMF{T<:AbstractFloat}(vnames::Vector{String}, p::Array{T})
    vlst = DVar{0}[dvar(v, 1:size(p,i)) for (i, v) in enumerate(vnames)]
    JointPMF{T}(VarList(vlst), p)
end

function JointPMF{T<:AbstractFloat,N}(vnames::NTuple{N,String}, p::Array{T,N})
    vlst = DVar{0}[dvar(v, 1:size(p,i)) for (i, v) in enumerate(vnames)]
    JointPMF{T}(VarList(vlst), p)
end

nvars(jp::JointPMF) = length(jp.varlist)
vars(jp::JointPMF) = jp.varlist
probs(jp::JointPMF) = jp.p

function show{T}(io::IO, jp::JointPMF{T})
    println(io, "JointPMF{$T} with $(nvars(jp)) variables:")
    for v in jp.varlist
        println(io, "  $(v.id): $(values(v.space))")
    end
end

#################################################
#
#   Compute marginals and conditionals
#
#################################################

function marginal(jp::JointPMF, vidx::Int)

end
