module Browse

    using CImGui
    using CImGui.ImGuiGLFWBackend
    using CImGui.ImGuiGLFWBackend.LibCImGui
    using CImGui.ImGuiGLFWBackend.LibGLFW
    using CImGui.ImGuiOpenGLBackend
    using CImGui.ImGuiOpenGLBackend.ModernGL
    using CImGui.CSyntax
    using Printf

    using Tables

    include("init.jl")
    include("render.jl")
    include("show_table.jl")
    include("macro.jl")

    mutable struct VisualizedTable
        table
        name::String 
        show::Bool
        i0
        i1  
    end
    
    global tables::Vector{VisualizedTable}

    # initialize
    tables = Vector{VisualizedTable}()

end # module
    