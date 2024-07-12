function renderloop(window, ctx, glfw_ctx, opengl_ctx, ui=()->nothing, hotloading=false)
    try
        while glfwWindowShouldClose(window) == 0
            glfwPollEvents()
            ImGuiOpenGLBackend.new_frame(opengl_ctx)
            ImGuiGLFWBackend.new_frame(glfw_ctx)
            CImGui.NewFrame()

            # hotloading ? Base.invokelatest(ui) : ui()
            ui()

            CImGui.Render()
            glfwMakeContextCurrent(window)

            width, height = Ref{Cint}(), Ref{Cint}() #! need helper fcn
            glfwGetFramebufferSize(window, width, height)
            display_w = width[]
            display_h = height[]

            glViewport(0, 0, display_w, display_h)
            glClearColor(0.2, 0.2, 0.2, 1)
            glClear(GL_COLOR_BUFFER_BIT)
            ImGuiOpenGLBackend.render(opengl_ctx)

            if unsafe_load(igGetIO().ConfigFlags) & ImGuiConfigFlags_ViewportsEnable == ImGuiConfigFlags_ViewportsEnable
                backup_current_context = glfwGetCurrentContext()
                igUpdatePlatformWindows()
                GC.@preserve opengl_ctx igRenderPlatformWindowsDefault(C_NULL, pointer_from_objref(opengl_ctx))
                glfwMakeContextCurrent(backup_current_context)
            end
            glfwSwapBuffers(window)
            yield()
        end
    catch e
        @error "Error in renderloop!" exception=e
        Base.show_backtrace(stderr, catch_backtrace())
    finally
        ImGuiOpenGLBackend.shutdown(opengl_ctx)
        ImGuiGLFWBackend.shutdown(glfw_ctx)
        CImGui.DestroyContext(ctx)
        glfwDestroyWindow(window)
    end
end

function render(ui; width=1280, height=720, title::AbstractString="Demo", hotloading=false)
    window, ctx, glfw_ctx, opengl_ctx = init_renderer(width, height, title)

    # try setting up docking?
    # ImGui::DockSpaceOverViewport(ImGui::GetMainViewport(), ImGuiDockNodeFlags_PassthruCentralNode);
    # CImGui.DockSpaceOverViewport(CImGui.GetMainViewport(), CImGui.ImGuiDockNodeFlags_PassthruCentralNode)

    GC.@preserve window ctx begin
        t = @async renderloop(window, ctx, glfw_ctx, opengl_ctx, ui, hotloading)
    end
    return t
end

function init(; window_width = 1280, window_height = 720, show_demo_window = false, show_framerate_window = false)

    # start the render loop
    render(width = window_width, height = window_height, title = "Browse.jl") do

        for t in Browse.tables
            t.show && @c Browse.show_table(&t.show, t.table, t.name, t.i0, t.i1)
        end
    
        show_demo_window && @c CImGui.ShowDemoWindow(&show_demo_window)

        # CImGui.Begin("TEST") 
        #     CImGui.Text("This is some useful text.")  # display some text

        #     # Flags for the table
        #     table_flags = CImGui.ImGuiTableFlags_(0)
        #     table_flags |= CImGui.ImGuiTableFlags_ScrollY
        #     table_flags |= CImGui.ImGuiTableFlags_ScrollX

        #     CImGui.BeginTable("table1", 5, table_flags)
        #         for n in 1:5
        #             CImGui.TableSetupColumn(":$(n)")
        #         end
        #         CImGui.TableHeadersRow()

        #         for row in 1:10
        #             CImGui.TableNextRow()
        #             for n in 1:5
        #                 CImGui.TableSetColumnIndex(n-1)
        #                 CImGui.TextUnformatted("$(n*2+row)")
        #             end
        #         end

        #     CImGui.EndTable()

        #     @c CImGui.Checkbox("Demo Window", &show_demo_window)  # edit bools storing our window open/close state
        #     @c CImGui.Checkbox("Another Window", &show_another_window)

        #     @c CImGui.SliderFloat("float", &f, 0, 1)  # edit 1 float using a slider from 0 to 1
        #     CImGui.ColorEdit3("clear color", clear_color)  # edit 3 floats representing a color
        #     CImGui.Button("Button") && (counter += 1)

        #     CImGui.SameLine()
        #     CImGui.Text("counter = $counter")
        #     CImGui.Text(@sprintf("Application average %.3f ms/frame (%.1f FPS)", 1000 / unsafe_load(CImGui.GetIO().Framerate), unsafe_load(CImGui.GetIO().Framerate)))

        # CImGui.End()

        # framerate window
        if show_framerate_window
            if CImGui.Begin("Framerate")
                CImGui.Text(@sprintf("Application average %.3f ms/frame (%.1f FPS)", 1000 / unsafe_load(CImGui.GetIO().Framerate), unsafe_load(CImGui.GetIO().Framerate)))
                CImGui.End()
            end
        end
    end

end