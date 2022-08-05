function Split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function GetFileExtension(url)
  return url:match("^.+(%..+)$")
end

function FileExists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function GetFileName(file)
    return file:match("^.+/(.+)$")
end

function GetFilePath(file)
    return file:match("(.*/)")
end

local function create_file()
    local file = vim.fn.expand("%:p")
    -- Double check that file gives a path, otherwise leave
    if string.len(file) <= 0 then
        print("error: no file open")
        return
    end
    -- Check that the file extension is valid (Scala for me)
    local ext = string.lower(GetFileExtension(file))
    if ext ~= ".scala" then
        print("error: not a supported file type")
    end
    -- If both are valid, generate the test file path (not the file, only the path)
    -- TODO: Not tested
    local file_split = Split(file, "/src/")
    if (#file_split) == 0 then
        print("error: invalid current location for buffer (should be in ../src/..*.scala)")
        return
    end

    if (#file_split) ~= 2 then
        print("error: several /src/ in path, can\'t decide where to put test file")
        return
    end
    
    local test_file_path = file_split[1] .. "/test/" .. file_split[2]

    -- Check if test file path exists (ie a test file already exists)
    if (FileExists(test_file_path)) then
        -- If the test file exists, return
        print("error: file already exists")
        return
    end

    -- else ask if the user wants to create the file there
    local question = "Do you want to create the following file:\n" .. test_file_path .. "\n(y)es or (n): "
    local confirmation = vim.fn.input(question, "", "file")

    if confirmation ~= "y" then
        print("cancelled file creation")
        return
    end

    -- if yes then create it - use some sort of snippet perhaps to generate the testfile?
    local final_filename = GetFileName(test_file_path)
    local final_path = GetFilePath(test_file_path)
    print("Creating file " .. test_file_path)
    vim.fn.mkdir(final_path, "p")
    print(test_file_path)
    vim.cmd[["writefile([], " .. test_file_path .. ")"]]
end


return {
    create_file = create_file,
}
