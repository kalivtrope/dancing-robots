-- modify package path to make the require command work
package.path = "./_modules/?.lua;" .. package.path
-- add a custom searcher utilizing FILEMAN because we don't have direct access to the filesystem here
local function load(modname)
  local errmsg = ""
  local modulepath = string.gsub(modname, "%.", "/")
  for path in string.gmatch(package.path, "([^;]+)") do
    local filename = THEME:GetPathB("", string.gsub(path, "%?", modulepath))
    if not FILEMAN:DoesFileExist(filename) then
      errmsg = errmsg .. "\n\tno file '" .. filename .. "' (custom loader)"
    else
      local loader, err = loadfile(filename)
      if err then
        error(err, 3)
      elseif loader then
        return loader
      end
    end
  end
  return errmsg
end
table.insert(package.searchers, 2, load)
