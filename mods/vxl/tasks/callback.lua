-- ONLY USED FOR UNIT TESTING, passing a function ref in a task's state will
-- break when loaded
return {
  plan = function(char, state)
    state.plan_cb(char, state)
  end,
  perform = function(char, state)
    state.perform_cb(char, state)
    return true
  end
}