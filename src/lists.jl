
mutable struct GroupedList{T}
    ng::Int                 # number of groups
    elems::Vector{T}        # concatenated element list
    offs::Vector{Int}       # offsets
end

"""Construct a grouped list from counts."""
function grlist_from_counts{T}(elems::Vector{T}, cnts::AbstractVector{Int})
    ng = length(cnts)
    offs = Vector{Int}(ng + 1)
    offs[1] = 0
    for k = 1:ng
        offs[k+1] = offs[k] + cnts[k]
    end
    offs[ng+1] == length(elems) ||
        throw(ArgumentError("Mismatch between sum(cnts) and length(elems)."))
    GroupedList{T}(ng, elems, offs)
end

"""Construct a grouped list by a group-index mapping function."""
function grlist_by{T}(es::AbstractVector{T}, ng::Int, f::Function)
    len = length(es)

    elems = Vector{T}(len)
    offs = Vector{Int}(ng + 1)
    cnts = zeros(Int, ng)
    for e in es
        k = f(e)::Int
        0 < k <= ng || throw(BoundsError("Group index out of bound."))
        cnts[k] += 1
    end

    offs[1] = 0
    for i = 1:ng
        offs[i+1] = offs[i] + cnts[i]
    end
    @assert offs[ng + 1] == len

    fill!(cnts, 0)
    for e in es
        k = f(e)::Int
        elems[1 + offs[k] + cnts[k]] = e
        cnts[k] += 1
    end
    GroupedList{T}(ng, elems, offs)
end

eltype{T}(gl::GroupedList{T}) = T
length(gl::GroupedList) = length(gl.elems)
ngroups(gl::GroupedList) = gl.ng

eachindex(gl::GroupedList) = eachindex(gl.elems)
getindex(gl::GroupedList, i) = gl.elems[i]

start(gl::GroupedList) = start(gl.elems)
next(gl::GroupedList, state) = next(gl.elems, state)
done(gl::GroupedList, state) = done(gl.elems, state)

group_length(gl::GroupedList, k::Int) = gl.offs[k+1] - gl.offs[k]
group(gl::GroupedList, k::Int) = view(gl.elems, gl.offs[k]+1:gl.offs[k+1])


"""
A list whose elements can be accessed by both index or name.
"""
mutable struct NamedList{T}
    elems::Vector{T}
    imap::Dict{String,Int}
end

"""Construct a named list from a list of named elements."""
function namedlist{T}(es::AbstractVector{T}, namefun::Function)
    elems = Vector{T}()
    imap = Dict{String,Int}()
    len = length(es)
    sizehint!(elems, len)
    sizehint!(imap, len)

    for e in es
        k = namefun(e)::String
        !haskey(imap, k) || throw(KeyError("Duplicated name: '$(k)'."))
        push!(elems, e)
        imap[k] = length(elems)
    end
    NamedList{T}(elems, imap)
end

"""Construct a named list from name-element pairs."""
function namedlist_from_pairs{T}(ps::AbstractVector{Tuple{String, T}})
    elems = Vector{T}()
    imap = Dict{String,Int}()
    len = length(ps)
    sizehint!(elems, len)
    sizehint!(imap, len)

    for (k, e) in ps
        !haskey(imap, k) || throw(KeyError("Duplicated name: '$(k)'."))
        push!(elems, e)
        imap[k] = length(elems)
    end
    NamedList{T}(elems, imap)
end

eltype{T}(nl::NamedList{T}) = T
ndims(nl::NamedList) = 1
length(nl::NamedList) = length(nl.elems)
size(nl::NamedList) = (length(nl),)

eachindex(nl::NamedList) = eachindex(nl.elems)
getindex(nl::NamedList, i::Int) = nl.elems[i]
getindex(nl::NamedList, id::String) = nl.elems[nl.imap[id]]

start(nl::NamedList) = start(nl.elems)
next(nl::NamedList, state) = next(nl.elems, state)
done(nl::NamedList, state) = done(nl.elems, state)

indexof(id::String, nl::NamedList) = nl.imap[id]
indexof(ids, nl::NamedList) = Int[indexof(id, nl) for id in ids]

function show{T}(io::IO, nl::NamedList{T})
    println(io, "NamedList{$T} with $(length(nl)) elements:")
    for e in nl.elems
        println(io, e)
    end
end
