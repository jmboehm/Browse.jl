using CImGui
using CImGui.CSyntax
using CImGui.CSyntax.CStatic

let
# examples Apps (accessible from the "Examples" menu)
# show_app_documents=false
# show_app_main_menu_bar=false
# show_app_console=false
# show_app_log=false
# show_app_layout=false
# show_app_property_editor=false
# show_app_long_text=false
# show_app_auto_resize=false
# show_app_constrained_resize=false
# show_app_simple_overlay=false
# show_app_window_titles=false
# show_app_custom_rendering=false
# # Dear ImGui apps (accessible from the "Help" menu)
# show_app_metrics = false
# show_app_style_editor = false
# show_app_about = false
# # demonstrate the various window flags. typically you would just use the default!
# no_titlebar = false
# no_scrollbar = false
# no_menu = false
# no_move = false
# no_resize = false
# no_collapse = false
# no_close = false
# no_nav = false
# no_background = false
# no_bring_to_front = false
"""
    show_table(p_open::Ref{Bool})
Show a Tables.jl compatible table as a window
"""
global function show_table(p_open::Ref{Bool}, table, table_name::String, i0, i1)

    no_close = false

    # # Dear ImGui apps (accessible from the "Help" menu)
    # show_app_metrics && @c CImGui.ShowMetricsWindow(&show_app_metrics)
    # if show_app_style_editor
    #     @c CImGui.Begin("Style Editor", &show_app_style_editor)
    #     CImGui.ShowStyleEditor()
    #     CImGui.End()
    # end
    # show_app_about && @c ShowAboutWindow(&show_app_about)

    # demonstrate the various window flags. typically you would just use the default!
    window_flags = CImGui.ImGuiWindowFlags(0)
    # no_titlebar       && (window_flags |= CImGui.ImGuiWindowFlags_NoTitleBar;)
    # no_scrollbar      && (window_flags |= CImGui.ImGuiWindowFlags_NoScrollbar;)
    # !no_menu          && (window_flags |= CImGui.ImGuiWindowFlags_MenuBar;)
    # no_move           && (window_flags |= CImGui.ImGuiWindowFlags_NoMove;)
    # no_resize         && (window_flags |= CImGui.ImGuiWindowFlags_NoResize;)
    # no_collapse       && (window_flags |= CImGui.ImGuiWindowFlags_NoCollapse;)
    # no_nav            && (window_flags |= CImGui.ImGuiWindowFlags_NoNav;)
    # no_background     && (window_flags |= CImGui.ImGuiWindowFlags_NoBackground;)
    # no_bring_to_front && (window_flags |= CImGui.ImGuiWindowFlags_NoBringToFrontOnFocus;)
    no_close && (p_open = C_NULL;) # don't pass our bool* to Begin

    # specify a default position/size in case there's no data in the .ini file.
    # typically this isn't required! we only do it to make the Demo applications a little more welcoming.
    # CImGui.SetNextWindowPos((0, 0))
    # CImGui.SetNextWindowSize((550, 680), CImGui.ImGuiCond_FirstUseEver)

    # i'm restricting the window to be smaller than the display size. if it's larger (-> large tables)
    # then crashes may happen
    ds = unsafe_load(CImGui.GetIO().DisplaySize)
    CImGui.SetNextWindowSizeConstraints(CImGui.ImVec2(100.0, 0.0), ds);

    # main body of the window starts here.
    CImGui.Begin("$(table_name) ($(size(table,1))x$(size(table,2)))", p_open, window_flags) || (CImGui.End(); return)
        
        # @cstatic i0=Cint(1) i1=Cint(1000) begin
            CImGui.InputInt("Start Row##$(table_name)", i0)
            CImGui.InputInt("End Row##$(table_name)", i1)
            show_start_row = i0[]
            show_end_row = i1[]
        # end

        # don't take zero or negative for start
        if show_start_row < 1
            show_start_row = 1
        end
        # if end < start, set end = start
        if show_end_row < show_start_row
            show_end_row = show_start_row
        end
        # don't go too long
        if show_end_row > size(table, 1)
            show_end_row = size(table, 1)
        end

        rows = Tables.rows(table[show_start_row:show_end_row, :])
        cols = Tables.Columns(table)
        s = Tables.schema(table)
        s.names
        s.types
        # Size 
        # outer_size = CImGui.ImVec2(0.0, TEXT_BASE_HEIGHT * 5)

        # Flags for the table
        table_flags = CImGui.ImGuiTableFlags_(0)
        table_flags |= CImGui.ImGuiTableFlags_RowBg
        table_flags |= CImGui.ImGuiTableFlags_Resizable 
        table_flags |= CImGui.ImGuiTableFlags_Reorderable 
        table_flags |= CImGui.ImGuiTableFlags_Hideable 
        table_flags |= CImGui.ImGuiTableFlags_Borders 
        table_flags |= CImGui.ImGuiTableFlags_ContextMenuInBody

        # principles for size: 
        # - show at least 4 columns

        rind = 0
        # outer_size = CImGui.ImVec2(min(size(table, 2)*100, window_width),min_table_height)
        CImGui.BeginTable("table1", length(s.names), table_flags, CImGui.ImVec2(0.0, 100.0) )

            # ImGui::TableSetupScrollFreeze(freeze_cols, freeze_rows);

            CImGui.TableSetupColumn("#", CImGui.ImGuiTableColumnFlags_NoHide);
            for n in s.names 
                CImGui.TableSetupColumn(":" * String(n))
            end
            CImGui.TableHeadersRow()

            for row in rows
                CImGui.TableNextRow()
                CImGui.TableSetColumnIndex(0)
                CImGui.TextUnformatted("$(show_start_row+rind)")
                Tables.eachcolumn(s, row) do val, i, nm
                    CImGui.TableSetColumnIndex(i)
                    CImGui.TextUnformatted("$val")
                end
                rind += 1
            end

        CImGui.EndTable()

    # # most "big" widgets share a common width settings by default.
    # # CImGui.PushItemWidth(CImGui.GetWindowWidth() * 0.65)    # use 2/3 of the space for widgets and 1/3 for labels (default)
    # CImGui.PushItemWidth(CImGui.GetFontSize() * -12)        # use fixed width for labels (by passing a negative value), the rest goes to widgets. We choose a width proportional to our font size.

    CImGui.End() # demo
end

end # let
