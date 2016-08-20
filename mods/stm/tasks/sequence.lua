return {
  plan = function(char, state)
    for _,task in ipairs(state) do
      char:push_task(task.name, task.state)
    end
  end,
  perform = function(char, state)
    return true
  end
}