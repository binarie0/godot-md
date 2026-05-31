@tool
extends EditorPlugin

var dockExtensionSetting = "docks/filesystem/textfile_extensions";
var dockOtherSetting = "docks/filesystem/other_file_extensions";

var saveLocation = "user://.local/md_panels.txt";
var activeTabLocation = "user://.local/md_active_tab.txt";
var localFolder = "user://.local"
var panel: Markdown_Preview_Panel

func _enter_tree() -> void:
	panel = preload("res://addons/godot_md/md_previewer_panel.tscn").instantiate() as Markdown_Preview_Panel;
	add_control_to_bottom_panel(panel, "MD Preview")
	# _remove_md_from_script_editor();
	load_data(panel);
	
func _remove_md_from_script_editor():
	
	# main setting
	var currentData := get_editor_interface().get_editor_settings().get_setting(dockExtensionSetting) as String;
	currentData = currentData.replace(",md", "");
	#print(currentData);
	get_editor_interface().get_editor_settings().set_setting(dockExtensionSetting, currentData);
	
	# still have the icon show up in the file system
	currentData = get_editor_interface().get_editor_settings().get_setting(dockOtherSetting) as String;
	if (!currentData.contains(",md")): currentData += ",md";
	get_editor_interface().get_editor_settings().set_setting(dockOtherSetting, currentData);
	
		
	

func _add_md_to_script_editor():
	
	# main setting
	var currentData := get_editor_interface().get_editor_settings().get_setting(dockExtensionSetting) as String;
	if (!currentData.contains(",md")): currentData += ",md";
	print(currentData);
	get_editor_interface().get_editor_settings().set_setting(dockExtensionSetting, currentData);
	
	# still have the icon show up in the file system
	currentData = get_editor_interface().get_editor_settings().get_setting(dockOtherSetting) as String;
	currentData = currentData.replace(",md", "");
	get_editor_interface().get_editor_settings().set_setting(dockOtherSetting, currentData);

func _handles(object: Object) -> bool:
	if (object is Resource):
		var r = object as Resource;
		return r.resource_path.ends_with(".md");
	return false;
	
func _make_visible(visible: bool) -> void:
	panel.visible = visible;
	if (visible):
		(panel.get_parent_control() as EditorDock).make_visible()
		var currentScene = get_editor_interface().get_edited_scene_root();
		get_editor_interface().set_main_screen_editor(
			"3D" if currentScene != null && currentScene.is_class("Node3D") else "2D"
		);
		
	
	
func _edit(object: Object) -> void:
	if (object == null): return;
	panel._load_file((object as Resource).resource_path);
	
func _exit_tree() -> void:
	if panel:
		save_data(panel);
		remove_control_from_bottom_panel(panel)
		panel.queue_free()
		#_add_md_to_script_editor()

func save_data(panel:Markdown_Preview_Panel) -> void:
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(localFolder)):
		DirAccess.make_dir_absolute(ProjectSettings.globalize_path(localFolder));
	var data = panel.panels;
	var activeTab = panel.tab_container.current_tab;
	var fa = FileAccess.open(saveLocation, FileAccess.WRITE);
	for file in data:
		fa.store_line(file);
	fa.close();
	
	fa = FileAccess.open(activeTabLocation, FileAccess.WRITE);
	fa.store_8(activeTab);
	fa.close();
	
	pass;
	
func load_data(panel:Markdown_Preview_Panel) -> void:	
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(localFolder)):
		DirAccess.make_dir_absolute(ProjectSettings.globalize_path(localFolder));
		return;
	if not (FileAccess.file_exists(saveLocation) and FileAccess.file_exists(activeTabLocation)):
		return;
	
	var fa = FileAccess.open(saveLocation, FileAccess.READ);
	var files := fa.get_as_text().split('\n');
	fa.close()
	
	fa = FileAccess.open(activeTabLocation, FileAccess.READ);
	var activeTab := fa.get_8()
	fa.close();
	
	panel._load_files(files);
	panel.tab_container.current_tab = activeTab;
	
	
	
	

	
