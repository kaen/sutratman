return {
  plan = function(char, state)
  end,
  perform = function(char, state)
    local site = Site.get(state.site)
    if site:is_complete() then
      return true
    else
      local order = site:get_next_order()
      if order then char:push_task('build_lazily', { order = order.id }) end
      return
    end
  end
}