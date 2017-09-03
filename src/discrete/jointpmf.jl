
#################################################
#
#   Type definitions and properties
#
#################################################

"""
Joint finite distribution represented by probability mass function.
"""
mutable struct JointPMF{T<:AbstractFloat}
    varlist::SVarList
    p::Array{T}

    function JointPMF{T}(vl::SVarList, p::Array{T}) where T<:AbstractFloat
        nv = length(vl)
        ndims(p) == nv ||
            throw(DimensionMismatch(
                "ndims(p) does not match the number of variables."))
        for i = 1:nv
            size(p,i) == cardinality(vl[i]) ||
                throw(DimensionMismatch(
                    "size(p,i) does not match the corresponding space size."))
        end
        new(vl, p)
    end
end

JointPMF{T<:AbstractFloat}(vl::VarList{SVar}, p::Array{T}) = JointPMF{T}(vl, p)

function JointPMF{T<:AbstractFloat}(vnames::Vector{String}, p::Array{T})
    vlst = SVar[dvar(v, size(p,i)) for (i, v) in enumerate(vnames)]
    JointPMF{T}(VarList(vlst), p)
end

function JointPMF{T<:AbstractFloat,N}(vnames::NTuple{N,String}, p::Array{T,N})
    vlst = SVar[dvar(v, size(p,i)) for (i, v) in enumerate(vnames)]
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
        return copy(probs(jp))::Vector{T}
    else
        reduc_region = Utils.range_rm(nvars(jp), vidx)
        _mp = sum(probs(jp), reduc_region)
        return reshape(_mp, size(_mp, vidx))::Vector{T}
    end
end

function marginal_i{T}(jp::JointPMF{T}, vinds)
    @assert !isa(vinds, Int)
    !isempty(vinds) || throw(ArgumentError("Input indices are empty."))

    # process the case for single variable
    if length(vinds) == 1
        return marginal_i(jp, first(vinds))
    end

    # marginalize out unspecified variables
    vinds_ = collect(vinds)::Vector{Int}
    reduc_region = Utils.range_rm(nvars(jp), vinds_)
    if isempty(reduc_region)
        # no remaining variables, just keep p
        mp = copy(probs(jp))
    else
        s_vinds = issorted(vinds_) ? vinds_ : sort(vinds_)
        # reduce along unspecified dimensions
        _mp = sum(probs(jp), reduc_region)
        # squeeze out reduced dimensions
        rsiz = ntuple(i->size(_mp, s_vinds[i]), length(s_vinds))
        mp = reshape(_mp, rsiz)
    end
    # make output, permute dimensions according to specified order
    issorted(vinds)    ? mp :
    length(vinds) == 2 ? transpose(mp) :
                         permutedims(mp, Utils.isortperm(vinds_))
end

marginal(jp::JointPMF, vids) = marginal_i(jp, indexof(vids, vars(jp)))

function conditional_i(jp::JointPMF, vinds, cinds)
    # no conditions, degenerate to marginal distribution
    if isempty(cinds)
        return marginal_i(jp, vinds)
    end

    # compute the marginal of both targets and conditions
    mp = marginal_i(jp, Int[vinds..., cinds...])

    # obtain the conditional probabilities
    mp ./= sum(mp, 1:length(vinds))
end

conditional(jp::JointPMF, vs, cs) =
    conditional_i(jp, indexof(vs, vars(jp)), indexof(cs, vars(jp)))
