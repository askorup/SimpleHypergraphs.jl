function conversionJSON(path::String)
    f = JSON.parsefile(path)
    hg = f["hg"]
    vertices = hg["vertices"]
    hyperedges = hg["hyperedges"]


    nodes = []
    links = []
    nodelinks = []


    Nodi = Dict()
    for (key,value) in vertices
        Nodi[key]=[]
    end



    for (keyLink, valueLink) in hyperedges
        Link = Dict()
        Link["id"]=keyLink
        vertici = []
        for (keyNodes, valueNodes) in valueLink["vertices"]
            nodelink = Dict()
            nodelink["node"]=keyNodes
            nodelink["link"]=keyLink
            nodelink["value"]=string(valueNodes)
            push!(nodelinks,nodelink)

            push!(vertici,string(keyNodes))

            linksdeinodi = Nodi[keyNodes]
            Nodi[keyNodes] = push!(linksdeinodi,keyLink)
        end
        Link["nodes"]=vertici
        push!(links,Link)
    end

    for (key,value) in Nodi
        Nodo = Dict()
        Nodo["id"]=key
        Nodo["links"]=value
        push!(nodes,Nodo)
    end

    Ipergrafo = Dict()
    Ipergrafo["nodes"]=nodes
    Ipergrafo["links"]=links
    Ipergrafo["nodelinks"]=nodelinks

    json_string = JSON.json(Ipergrafo)

    return json_string
    end

function generateFileJSON(h::Hypergraph, path::String="")
    n_ver,n_he=size(h)
    s="{"


    sNodes="
    \"nodes\":["
    x=1
    for x in 1:n_ver
        sNodes=sNodes*"
        {\"id\":\""*string(x)*"\" , \"links\":["
        flag=true;
        y=1
        for y in 1:n_he
            if getindex(h,x,y)!=nothing
                sNodes=sNodes*"\""*string(y)*"\","
                flag=false;
            end
        end
        if flag==false
            sNodes=chop(sNodes);
        end
        sNodes=sNodes*"]},"
    end
    sNodes=chop(sNodes);
    sNodes=sNodes*"
    ],"




    sLinks="
    \"links\":["
    x=1
    for x in 1:n_he
        sLinks=sLinks*"
        {\"id\":\""*string(x)*"\", \"nodes\": ["
        flag=true;
        y=1
        for y in 1:n_ver
            if getindex(h,y,x)!=nothing
                sLinks=sLinks*"\""*string(y)*"\","
                flag=false;
            end
        end
        if flag==false
            sLinks=chop(sLinks)
        end
        sLinks=sLinks*"]},"
    end
    sLinks=chop(sLinks)
    sLinks=sLinks*"
    ],"



    sNodeLinks="
    \"nodelinks\":["
        x=1
        for x in 1:n_ver
            y=1
            for y in 1:n_he
                if getindex(h,x,y)!=nothing
                    sNodeLinks=sNodeLinks*"
                    {\"node\":\""*string(x)*"\",\"link\":\""*string(y)*"\",\"value\":\""*string(getindex(h,x,y))*"\"},"
                end
            end
        end
        sNodeLinks=chop(sNodeLinks)
        sNodeLinks=sNodeLinks*"
        ]
    }"




s=s*sNodes*sLinks*sNodeLinks

        if path != ""
            open(path,"w") do f
                write(f, s)
        end
        elseif path == ""
            open("data.json", "w") do f
                write(f, s)
        end

    end

end
