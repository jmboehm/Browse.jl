import CImGui as ig
import GLFW, ModernGL
import CSyntax: @c, @cstatic
using Printf
using Random
# using ImPlot

ig.set_backend(:GlfwOpenGL3)


function official_demo(; engine=nothing)
    # setup Dear ImGui context
    ctx = ig.CreateContext()

    show_demo_window = true

    ig.render(ctx; engine) do
        # show the big demo window
        show_demo_window && @c ig.ShowDemoWindow(&show_demo_window)
        
        if ig.Begin("test win") 
        
            @cstatic(
                flags = ig.ImGuiTableFlags_BordersOuter | ig.ImGuiTableFlags_BordersV | ig.ImGuiTableFlags_RowBg,
                offset = 0,
                data = zeros(Float32, 100),
            begin
                ig.BulletText("Plots can be used inside of ImGui tables.")
                if ig.BeginTable("##table", 3, flags, ig.ImVec2(-1,0))
                    ig.TableSetupColumn("Electrode", ig.ImGuiTableColumnFlags_WidthFixed, 75.0)
                    ig.TableSetupColumn("Voltage", ig.ImGuiTableColumnFlags_WidthFixed, 75.0)
                    ig.TableSetupColumn("EMG Signal")
                    ig.TableHeadersRow()
                    for row = 0:9  #? 1:10
                        ig.TableNextRow()
                        Random.seed!(row)
                        for i = 1:100
                            data[i] = rand(0.0 : 0.0001 : 10.0)
                        end
                        ig.TableSetColumnIndex(0)
                        ig.Text(@sprintf("EMG %d", row))
                        ig.TableSetColumnIndex(1)
                        ig.Text(@sprintf("%.3f V", data[offset + 1]))
                        ig.TableSetColumnIndex(2)
                        ig.PushID(row)
                        ig.PopID()
                    end
                    ig.EndTable()
                end
            end)

            ig.End()

        end

        # show a simple window that we create ourselves.
        # we use a Begin/End pair to created a named window.
        @cstatic f=Cfloat(0.0) counter=Cint(0) begin
            if ig.Begin("Hello, world!")
                framerate = unsafe_load(ig.GetIO().Framerate)

                @c ig.Checkbox("Show ImPlot Demo", &show_demo_window)
                ig.Text(@sprintf("Application average %.3f ms/frame (%.1f FPS)",
                                 1000 / framerate, framerate))

                ig.End()
            end
        end
    end
end

# Run automatically if the script is launched from the command-line
if !isempty(Base.PROGRAM_FILE)
    official_demo()
end
