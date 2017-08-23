
"""
The base type for underlying value spaces of random variables.
"""
abstract type ValueSpace
end

==(s1::ValueSpace, s2::ValueSpace) = false
!=(s1::ValueSpace, s2::ValueSpace) = !(s1 == s2)

"""
Real value space
"""
struct RealSpace <: ValueSpace
end

==(s1::RealSpace, s2::RealSpace) = true

show(io::IO, s::RealSpace) = print(io, "RealSpace")

"""
Finite value space.

With a finite space, a variable can only take values from a finite set.

A finite space comes with a ``size`` method:

- ``length(s)``:        get the number of distinct values.
- ``values(s)``:        get a collection of contained values.
- ``indexof(x, s)``:    get the index of `x` in the space.
"""
abstract type FiniteSpace <: ValueSpace
end

struct RangeSpace <: FiniteSpace
    values::UnitRange{Int}
end

values(s::RangeSpace) = s.values
length(s::RangeSpace) = length(s.values)

function indexof(x::Int, s::RangeSpace)
    x in s.values || throw(ArgumentError("Value not in range."))
    x - first(s.values) + 1
end

==(s1::RangeSpace, s2::RangeSpace) = (s1.values == s2.values)

show(io::IO, s::RangeSpace) = print(io, "RangeSpace($(s.values))")

"""
Random variable.

``Var`` is a parametric type with two type parameters:

- ``S``: The underlying value space.
- ``N``: The number of dimensions.

Each instance of ``Var`` represents a random variable that can take
different values in different trials. The instance contains four
public fields:

- ``id::String``:       The identifier of the variable. In a joint model,
                        each variable should have a unique id.
- ``space::S``:         The underlying value space (for each element).
- ``dims::Dims{N}``:    The dimensions of each sample.
- ``len::Int``:         The number of elements in each sample
                        (i.e. ``prod(size)``).
"""
struct Var{S<:ValueSpace,N}
    id::String
    space::S
    dims::Dims{N}
    len::Int

    function Var{S,N}(id::String, s::S, dims::Dims{N}) where {S<:ValueSpace,N}
        new(id, s, dims, prod(dims))
    end
end

const DVar{N} = Var{RangeSpace, N}
const RVar{N} = Var{RealSpace, N}

Var{S<:ValueSpace,N}(id::String, s::S, dims::Dims{N}) = Var{S,N}(id, s, dims)

dvar(id::String, rgn::UnitRange{Int}) = Var(id, RangeSpace(rgn), ())
dvar(id::String, rgn::UnitRange{Int}, n::Int) = Var(id, RangeSpace(rgn), (n,))
dvar(id::String, rgn::UnitRange{Int}, dims::Dims) = Var(id, RangeSpace(rgn), dims)
rvar(id::String) = Var(id, RealSpace(), ())
rvar(id::String, n::Int) = Var(id, RealSpace(), (n,))
rvar(id::String, dims::Dims) = Var(id, RealSpace(), dims)

ndims{S,N}(v::Var{S,N}) = N
size(v::Var) = v.dims
length(v::Var) = v.len

==(x::Var, y::Var) = (x.id == y.id && x.space == y.space && x.dims == y.dims)
!=(x::Var, y::Var) = !(x == y)

function show(io::IO, v::Var)
    print(io, "Var($(v.id))[space=$(v.space), dims=$(v.dims)]")
end


"""
An ordered list of random variables.

An instance of `VarList` has the following features:
- It ensures that all variables in the list have different ids.
- A variable can be retrieved by id or index.
"""
struct VarList{V<:Var}
    varlist::Array{V}
    imap::Dict{String,Int}

    function VarList{V}(vars) where V<:Var
        varlist = V[]
        imap = Dict{String,Int}()
        for v::V in vars
            if haskey(imap, v.id)
                throw(KeyError("Duplicated variable id: $(v.id)."))
            else
                push!(varlist, v)
                imap[v.id] = length(varlist)
            end
        end
        new(varlist, imap)
    end
end

VarList(vars) = VarList{eltype(vars)}(vars)

eltype{V}(vl::VarList{V}) = V
ndims(vl::VarList) = 1
length(vl::VarList) = length(vl.varlist)
size(vl::VarList) = (length(vl),)
getindex(vl::VarList, i::Int) = vl.varlist[i]
getindex(vl::VarList, id::String) = vl.varlist[vl.imap[id]]

eachindex(vl::VarList) = eachindex(vl.varlist)
start(vl::VarList) = start(vl.varlist)
next(vl::VarList, state) = next(vl.varlist, state)
done(vl::VarList, state) = done(vl.varlist, state)

indexof(id::String, vl::VarList) = vl.imap[id]

function show{V}(io::IO, vl::VarList{V})
    println(io, "VarList{$V} with $(length(vl)) variables:")
    for v in vl
        println(io, v)
    end
end
