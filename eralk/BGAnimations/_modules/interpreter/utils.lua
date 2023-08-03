local function dump(o)
  -- borrowed from: https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

return {
  dump = dump,
  write_stderr = function(msg)
    io.stderr:write(msg)
  end,
  assert_type = function (var, var_str, type_str)
    assert(type(var) == type_str, string.format("%s must be a %s (got %s)", var_str, type_str, type(var)))
  end,
  assert_bounds = function (var, var_str, min, max)
    if not max then
      assert(min <= var, string.format("variable '%s' = %d out of bounds [%d, inf]", var_str, var, min))
    else
      assert(min <= var and var <= max, string.format("variable '%s' = %d out of bounds [%d, %d]", var_str, var, min, max))
    end
  end,
}
