import os

BUILD_NUM=os.environ.get("BUILD_NUM")

with open("./pubspec.yaml", "r+") as file:
    content = file.read()
    content_list = content.split("\n")
    # print(content_list)
    for index, line in enumerate(content_list):
        if (line.startswith("version:")): 
            original_text = line
            without_build_number = original_text[:original_text.find("+")]
            new_version_with_build_number = without_build_number + f"+{BUILD_NUM}"
            string_index = index
    print(new_version_with_build_number)
    content_list[string_index] = new_version_with_build_number
    new_yaml = """{}""".format("\n".join(content_list))
    file.seek(0)
    file.write(new_yaml)
