module SimpleHypergraphs

using LightGraphs
using JSON

export Hypergraph, getvertices, gethyperedges
export hg_load, hg_save, export_json, load_json
export add_vertex!, add_hyperedge!
export set_vertex_meta!, get_vertex_meta
export set_hyperedge_meta!, get_hyperedge_meta
export BipartiteView, shortest_path
export TwoSectionView

export nhv, nhe
export modularity, randompartition
export AbstractCommunityFinder, CFModularityRandom, findcommunities

include("hypergraph.jl")
include("bipartite.jl")
include("io.jl")
include("twosection.jl")
include("modularity.jl")

end # module
