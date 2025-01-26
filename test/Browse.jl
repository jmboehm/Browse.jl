using Revise, RDatasets
using DataFrames
using Printf
# using GLFW

include("../src/Browse.jl")

using .Browse

using CImGui
using CImGui.CSyntax
using CImGui.CSyntax.CStatic

try
    rm("/Users/jboehm/imgui.ini")
catch
end
try
    rm("imgui.ini")
catch
end

global window_width = 1280
global window_height = 720

df_name = "random"
N = 10
df = DataFrame(index = collect(1:N), sqrt = sqrt.(1:N), cubrt = (1:N).^(1/3), qrt = (1:N).^(1/4))

# Browse.init_renderer()

Browse.init()

Browse.@browse df

df2 = dataset("datasets", "iris")


df2.test1 = df2.PetalWidth .+ 1.0
for i = 2:20
    df2[!, Symbol("test$(i)")] = df2[!, Symbol("test$(i-1)")] .+ 1.0 
end

Browse.@browse df2

using Random
N = 5
df2 = DataFrame(index = collect(1:N), r = rand(Float64, N))

Browse.@browse df2




show_df = true

CImGui.SetNextWindowPos((0, 0))
CImGui.SetNextWindowSize((550, 680))
global i0::Cint =1
global i1::Cint =1000

push!(Browse.tables, @c Browse.VisualizedTable(df, df_name, show_df, &i0, &i1) )

df.test = df.qrt .+ 3.0;

using Random
df_name = "random2"
N = 5_000
df2 = DataFrame(index = collect(1:N), r = rand(Float64, 5_000))

global j0::Cint =1
global j1::Cint =1000

CImGui.SetNextWindowPos((0, 0))
CImGui.SetNextWindowSize((550, 680))

push!(Browse.tables, @c Browse.VisualizedTable(df2, df_name, true, &j0, &j1) )

# show_random2 = true
# @c Browse.show_table2(&show_random2, df2, "random2")
##### TEST 

# Browse.render(width = window_width, height = window_height, title = "Browse.jl") do
#     if CImGui.Begin("Framerate")
#         CImGui.Text(@sprintf("Application average %.3f ms/frame (%.1f FPS)", 1000 / unsafe_load(CImGui.GetIO().Framerate), unsafe_load(CImGui.GetIO().Framerate)))
#         # image = rand(GLubyte, 4, img_width, img_height)
#         # ImGuiOpenGLBackend.ImGui_ImplOpenGL3_UpdateImageTexture(image_id, image, img_width, img_height)
#         # CImGui.Image(Ptr{Cvoid}(image_id), CImGui.ImVec2(img_width, img_height))
#         CImGui.End()
#     end
# end

#####

let 
    # import the globals from above
    global show_df_window, show_demo_window
    global min_table_height, min_table_width
    global window_width, window_height

    show_demo_window = true
    # global show_start_row, show_end_row

    # CImGui.SetNextWindowPos((0, 0))
    # CImGui.SetNextWindowSize((table_width, table_height))

    # TEXT_BASE_HEIGHT = CImGui.GetTextLineHeightWithSpacing()

    # set window position 
        # CImGui.SetNextWindowPos((20, 20))
        # CImGui.SetNextWindowSize((300, 300))

    Browse.render(width = window_width, height = window_height, title = "Browse.jl") do

        show_df_window && @c Browse.show_table(&show_df_window, df, df_name)
    
        show_demo_window && @c CImGui.ShowDemoWindow(&show_demo_window)

        # framerate window
        if CImGui.Begin("Framerate")
            CImGui.Text(@sprintf("Application average %.3f ms/frame (%.1f FPS)", 1000 / unsafe_load(CImGui.GetIO().Framerate), unsafe_load(CImGui.GetIO().Framerate)))
            CImGui.End()
        end

    end

end

#  , CImGui.ImVec2(-1,0)

# df.test2 = df.sqrt .+ 1.0;
# df.test3 = df.sqrt .+ 1.0;
# df.test4 = df.sqrt .+ 1.0;
# df.test5 = df.sqrt .+ 1.0;
# df.test6 = df.sqrt .+ 1.0;
# df.test7 = df.sqrt .+ 1.0;
# df.test8 = df.sqrt .+ 1.0;
# df.test9 = df.sqrt .+ 1.0;
