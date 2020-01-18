local eventtap = require 'hs.eventtap'
local timer = require 'hs.timer'
local apps = require 'apps'
local window = require 'hs.window'
local logger = hs.logger.new('chrome', 'debug')

local mod = {}

mod.name = 'Google Chrome'

mod.tab = {slack = ' Alloy Slack', mail = {work = 'Alloy, Inc. Mail', personal = 'jmartin.ca Mail'}}

local function wait(n)
  local n = n or 1
  timer.usleep(10000 * n)
end

function openSlack()
  mod.activateTab(mod.tab.slack)()
end

function mod.slackQuickSwitcher()
  openSlack()
  wait(2)
  eventtap.keyStroke({'cmd'}, 'k')
end

function mod.slackReactionEmoji(chars)
  return function()
    eventtap.keyStroke({'cmd', 'shift'}, '\\')
    wait()
    eventtap.keyStrokes(chars)
    wait(20)
    eventtap.keyStroke({}, 'return')
  end
end

function mod.slackUnread()
  openSlack()
  wait()
  eventtap.keyStroke({'cmd', 'shift'}, 'a')
end

function mod.openOmni()
  apps.switchToAndType(mod.name, {'shift'}, 't')
end

function mod.activateTab(name)
  return function()
    hs.osascript.javascript([[
      var chrome = Application('Google Chrome');
      chrome.activate();
      var wins = chrome.windows;

      // loop tabs to find a web page with a title of <name>
      function main() {
      for (var i = 0; i < wins.length; i++) {
      var win = wins.at(i);
      var tabs = win.tabs;
      for (var j = 0; j < tabs.length; j++) {
      var tab = tabs.at(j);
      tab.title(); j;
      if (tab.title().indexOf(']] .. name .. [[') > -1) {
        win.activeTabIndex = j + 1;
        return;
        }
        }
        }
        }
        main();
        ]])
    window.find(name):focus()
  end
end

return mod
