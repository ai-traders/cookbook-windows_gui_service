# Script to elevate shortcut to 'Run as Administrator'
ammend_shortcut = "C:\\Windows\\Temp\\ammend_shortcut.vbs"
cookbook_file ammend_shortcut do
  source "ammend_shortcut.vbs"
end
