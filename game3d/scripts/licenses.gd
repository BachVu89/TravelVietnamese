class_name TravelLicenses
extends RefCounted

static func full_text() -> String:
	var text := "DỌC MIỀN VIỆT 3D · GIẤY PHÉP VÀ NGUỒN\n\nGODOT ENGINE\n" + Engine.get_license_text()
	text += "\n\nDỮ LIỆU ĐỊA DANH\nNguồn và phạm vi: res://data/geography/sources.json\nDanh mục 34 tỉnh/thành và 13 vùng đảo; không phải toàn bộ đảo Việt Nam.\n\n"
	text += FileAccess.get_file_as_string("res://data/geography/LICENSE-vietnamese-provinces-database.txt")
	text += "\n\nGODOT THIRD-PARTY COPYRIGHT NOTICES\n"
	for component in Engine.get_copyright_info():
		text += "\n" + str(component.get("name", "")) + "\n"
		for part in component.get("parts", []):
			for notice in part.get("copyright", []):
				text += str(notice) + "\n"
			text += "License: " + str(part.get("license", "")) + "\n"
	text += "\n\nTHIRD-PARTY LICENSE TEXTS\n"
	var licenses := Engine.get_license_info()
	var names := licenses.keys()
	names.sort()
	for name in names:
		text += "\n\n" + str(name) + "\n" + str(licenses[name])
	return text
