macro browse(t::Symbol)
    i0 = gensym("$(String(t))_i0")
    i1 = gensym("$(String(t))_i1")
    tstring = String(t)
    return esc(
        quote
            global $i0::Cint =1
            global $i1::Cint =1000

            CImGui.SetNextWindowPos((0, 0))
            CImGui.SetNextWindowSize((550, 680))

            push!(Browse.tables, @c Browse.VisualizedTable($t, $tstring, true, &$i0, &$i1) )
        end
    )
end