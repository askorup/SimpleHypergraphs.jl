# TODO: maybe more fancy file format and correctness checking should be done


"""
    hg_save(io::IO, h::Hypergraph)

Saves a hypergraph `h` to an output stream `io`.

"""
function hg_save(io::IO, h::Hypergraph)
    println(io, length(h.v2he), " ", length(h.he2v))
    for he in h.he2v
        skeys = sort(collect(keys(he)))
        println(io, join(["$k=$(he[k])" for k in skeys], ' '))
    end
end

"""
    hg_save(fname::AbstractString, h::Hypergraph)

Saves a hypergraph `h` to a file `fname`.

"""
hg_save(fname::AbstractString, h::Hypergraph) =
    open(io -> hg_save(io, h), fname, "w")

"""
    hg_load(fname::AbstractString, T::Type{<:Real})

Loads a hypergraph from a stream `io`. The second argument
`T` represents type of data in the hypegraph.

Skips an initial comment.

"""
function hg_load(io::IO, T::Type{<:Real})
    line = readline(io)

    if startswith(line, "\"\"\"")
      singleline = true
        while(
            !( (!singleline && endswith(line, "\"\"\"")) ||
            (singleline && endswith(line, "\"\"\"") && length(line)>5)
            ) &&
            !eof(io)
            )
                line = readline(io)
                singleline = false
        end
        if eof(io)
            throw(ArgumentError("malformed input"))
        end
       line = readline(io)
    end

    l = split(line)
    length(l) == 2 || throw(ArgumentError("expected two integers"))
    n, k = parse.(Int, l)
    h = Hypergraph{T}(n, k)
    lastv = 0
    for i in 1:k
        for pos in split(readline(io))
            entry = split(pos, '=')
            length(entry) == 2 || throw(ArgumentError("expected vertex=weight"))
            v = parse(Int, entry[1])
            w = parse(T, entry[2])
            if v > lastv
                lasti = v
            else
                throw(ArgumentError("vertices in hyperedge must be sorted"))
            end
            h[v, i] = w
        end
    end
    # we ignore lines beyond k+1 in the file
    h
end

"""
    hg_load(fname::AbstractString, T::Type{<:Real})

Loads a hypergraph from a file `fname`. The second argument
`T` represents type of data in the hypegraph

"""
hg_load(fname::AbstractString, T::Type{<:Real}) =
    open(io -> hg_load(io, T), fname, "r")


    """
        export_json(io::IO, h::Hypergraph)
    Export a hypergraph `h` metadata to an output stream `io` in json format.
    """
    function export_json(io::IO, h::Hypergraph)
        """
            Example hypergraph:
            `h = Hypergraph{Float64,Any}(5,4)
            h[1:3,1] .= 1.5
            h[3,4] = 2.5
            h[2,3] = 3.5
            h[4,3:4] .= 4.5
            h[5,4] = 5.5
            h[5,2] = 6.5
            b = Business(:id_b,:name_b,:city_b,:state_b,1.0,1.0,3.5,10,[:cat1,:cat2])
            set_vertex_meta!(h, Array{Symbol,1}([:a,:b]),1)
            set_vertex_meta!(h, b, 2)
            export_json("hmetadata.json", h)`
            Output:
            Formatted JSON Data
            `{
               "hg":{
                  "nvertices":5,
                  "nhyperedges":4,
                  "vertices":{
                     "1":[
                        "a",
                        "b"
                     ],
                     "2":{
                        "id":"id_b",
                        "name":"name_b",
                        "city":"city_b",
                        "state":"state_b",
                        "lat":1.0,
                        "lng":1.0,
                        "stars":3.5,
                        "reviewcount":10,
                        "categories":[
                           "cat1",
                           "cat2"
                        ]
                     },
                     "3":null,
                     "4":null,
                     "5":null
                  },
                  "hyperedges":{
                     "1":{
                        "metadata":null,
                        "vertices":{
                           "2":1.5,
                           "3":1.5,
                           "1":1.5
                        }
                     },
                     "2":{
                        "metadata":null,
                        "vertices":{
                           "5":6.5
                        }
                     },
                     "3":{
                        "metadata":null,
                        "vertices":{
                           "4":4.5,
                           "2":3.5
                        }
                     },
                     "4":{
                        "metadata":null,
                        "vertices":{
                           "4":4.5,
                           "3":2.5,
                           "5":5.5
                        }
                     }
                  }
               }
            }`
        """
        nvertices, nhyperedges = size(h)
        towrite = "{\"hg\":{\"nvertices\":$(nvertices),\"nhyperedges\":$(nhyperedges),\"vertices\":{"

        for nodeid = 1:nvertices
            towrite = towrite * "\"$(nodeid)\":"
            nodemetadata = get_vertex_meta(h, nodeid)
            towrite = towrite * json(nodemetadata)

            if nodeid != nvertices
                towrite = towrite * ","
            end

            print(io, towrite)
            towrite = ""
        end

        towrite = "},\"hyperedges\":{"

        for edgeid = 1:nhyperedges
            towrite = towrite * "\"$(edgeid)\":{\"metadata\":"
            edgemetadata = get_hyperedge_meta(h, edgeid)
            towrite = towrite * json(edgemetadata) * ",\"vertices\":"

            edgevertices = getvertices(h, edgeid)
            towrite = towrite * json(edgevertices) * "}"

            if edgeid != nhyperedges
                towrite = towrite * ","
            else
                towrite = towrite * "}}}"
            end

            print(io, towrite)
            towrite = ""
        end
    end


    """
        export_json(fname::AbstractString, h::Hypergraph)
    Export a hypergraph `h` metadata to a file `fname` in json format.
    """
    export_json(fname::AbstractString, h::Hypergraph) =
        open(io -> export_json(io, h), fname, "w")


    """
        load_json(io::IO, T::Type{<:Real}, V::Any=Nothing, E::Any=Nothing)
    Loads a hypergraph from a stream `io`.
    **Arguments**
    * `T` : type of weight values stored in the hypergraph
    * `V` : type of values stored in the vertices of the hypergraph
    * `E` : type of values stored in the edges of the hypergraph
    """
    function load_json(io::IO, T::Type{<:Real}, V::Any=Nothing, E::Any=Nothing)
        hg_json = JSON.parse(io)
        h = Hypergraph{T,V,E}(hg_json["hg"]["nvertices"], hg_json["hg"]["nhyperedges"])

        for he in keys(hg_json["hg"]["hyperedges"])
            he_vertices = hg_json["hg"]["hyperedges"][he]["vertices"]
            for v in keys(he_vertices)
                h[parse(Int, v), parse(Int, he)] = he_vertices[v]
            end
            hg_json["hg"]["hyperedges"][he]["metadata"] === nothing ||
                set_hyperedge_meta!(h, hg_json["hg"]["hyperedges"][he]["metadata"], parse(Int, he))
        end

        for v in keys(hg_json["hg"]["vertices"])
            hg_json["hg"]["vertices"][v] === nothing ||
                set_vertex_meta!(h, hg_json["hg"]["vertices"][v], parse(Int, v))
        end

        h
    end

    """
        load_json(fname::AbstractString, T::Type{<:Real}, V::Any=Nothing, E::Any=Nothing)
    Loads a hypergraph from a file `fname`.
    **Arguments**
    * `T` : type of weight values stored in the hypergraph
    * `V` : type of values stored in the vertices of the hypergraph
    * `E` : type of values stored in the edges of the hypergraph
    """
    load_json(fname::AbstractString, T::Type{<:Real}, V::Any=Nothing, E::Any=Nothing) =
        open(io -> load_json(io, T, V, E), fname, "r")
