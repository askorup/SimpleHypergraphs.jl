module SimpleHypergraphs

using LightGraphs

#visualization
using PyCall
using GraphPlot
using JSON
using IJulia

export Hypergraph, getvertices, gethyperedges
export hg_load, hg_save, hg_export_json
export add_vertex!, add_hyperedge!
export set_vertex_meta!, get_vertex_meta
export set_hyperedge_meta!, get_hyperedge_meta
export BipartiteView, shortest_path
export TwoSectionView

export nhv, nhe
export modularity, randompartition
export AbstractCommunityFinder, CFModularityRandom, findcommunities

#visualization
export hgplot
export generateFileJSON

include("hypergraph.jl")
include("bipartite.jl")
include("io.jl")
include("twosection.jl")
include("modularity.jl")

#visualization
include("visualization/plot.jl")
include("visualization/util.jl")
include("visualization/wrapper.jl")
include("visualization/widgets.jl")

end # module
