do

  local function cb_getdialog(extra, success, result)
    vardump(extra)
    vardump(result)
  end

  local function parsed_url(link)
    local parsed_link = URL.parse(link)
    local parsed_path = URL.parse_path(parsed_link.path)
    for k,segment in pairs(parsed_path) do
      if segment == 'joinchat' then
        invite_link = parsed_path[k+1]:gsub('[ %c].+$', '')
        break
      end
    end
    return invite_link
  end

  local function action_by_reply(extra, success, result)
    local hash = parsed_url(result.text)
    join = import_chat_link(hash, ok_cb, false)
  end

--------------------------------------------------------------------------------

  function run(msg, matches)

    if not is_sudo(msg) then
      return
    end

    if matches[1] == '$' then
      local header = '$'..matches[2]..'\n'
      local stdout = io.popen(matches[2]):read('*all')
      return stdout
    end
    
    if matches[1] == "block" then
      block_user("user#id"..matches[2], ok_cb, false)

      if is_mod(matches[2], msg.to.peer_id) then
        return "You can't block moderators."
      end
      if is_admin(matches[2]) then
        return "You can't block administrators."
      end
      block_user("user#id"..matches[2], ok_cb, false)
      return "User blocked"
    end

    if matches[1] == "unblock" then
      unblock_user("user#id"..matches[2], ok_cb, false)
      return "User unblocked"
    end

    if matches[1] == "import" then
      if msg.reply_id then
        get_message(msg.reply_id, action_by_reply, msg)
      elseif matches[2] then
        local hash = parsed_url(matches[2])
        join = import_channel_link(hash, ok_cb, false)
      end
    end
  end

  --------------------------------------------------------------------------------

  return {
    description = 'Various sudo commands.',
    patterns = {
      '^($)(.*)$',
      '^[/!](block) (.*)$',
      '^[/!](unblock) (.*)$',
      '^[/!](block) (%d+)$',
      '^[/!](unblock) (%d+)$',
      '^[/!](import)$',
      '^[/!](import) (.*)$',
    },
    run = run
  }

end
