
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

function marginal_i{T}(jp::JointPMF{T}, vidx::Int)
    if nvars(jp) == 1
        vidx == 1 || throw(BoundsError("Variable index out of range."))
        return probs(jp)::Vector{T}
    else
        reduc_region = Utils.range_rm(nvars(jp), vidx)
        _mp = sum(probs(jp), reduc_region)
        return reshape(_mp, size(_mp, vidx))::Vector{T}
    end
end

function marginal_i{T}(jp::JointPMF{T}, vinds)
    @assert !isa(vinds, Int)
    !isempty(vinds) || throw(ArgumentError("Input indices are empty."))

    if length(vinds) == 1
        return marginal_i(jp, first(vinds))
    end

    vinds_ = collect(vinds)::Vector{Int}
    reduc_region = Utils.range_rm(nvars(jp), vinds_)
    if isempty(reduc_region)
        mp = probs(jp)
    else
        s_vinds = issorted(vinds_) ? vinds_ : sort(vinds_)
        _mp = sum(probs(jp), reduc_region)
        rsiz = ntuple(i->size(_mp, s_vinds[i]), length(s_vinds))
        mp = reshape(_mp, rsiz)
    end
    return issorted(vinds)    ? mp :
           length(vinds) == 2 ? transpose(mp) :
                                permutedims(mp, Utils.isortperm(vinds_))
end

marginal(jp::JointPMF, vid::String) = marginal_i(jp, indexof(vid, vars(jp)))
marginal(jp::JointPMF, vids) = marginal_i(jp, Int[indexof(v, vars(jp)) for v in vids])
