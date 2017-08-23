module Utils

function range_rm(n::Int, s::Int)
    @assert n > 0
    0 < s <= n || throw(BoundsError("Given index is out of range."))
    r = Vector{Int}(n - 1)
    for i = 1:(s-1)
        r[i] = i
    end
    for i = (s+1):n
        r[i-1] = i
    end
    r
end

function range_rm(n::Int, s)
    @assert n >= length(s)
    b = fill(false, n)
    for idx in s
        0 < idx <= n || throw(BoundsError("Given index is out of range."))
        b[idx] && throw(ArgumentError("Duplicated indexes."))
        b[idx] = true
    end
    rlen = n - length(s)
    r = Vector{Int}(rlen)
    j = 1
    for i = 1:n
        if !b[i]
            r[j] = i
            j += 1
        end
    end
    @assert j == rlen + 1
    r
end

function isortperm(s)
    n = length(s)
    a = Vector{Int}(n)
    a[sortperm(s)] = 1:n
    a
end

end # Module Utils
