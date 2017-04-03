#
# The MIT License (MIT)
#
# Copyright (c) 2015 AI-Traders
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class WindowsGuiService < Chef::Provider::LWRPBase

      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create do
        user = node[:windows_gui_service][:autologin][:user]
        executable = new_resource.executable
        elevate = new_resource.elevate
        # create a link for future boots
        # startup directory as in http://answers.microsoft.com/en-us/windows/forum/windows_7-system/how-to-get-startup-folder-in-start-all-programs/d3f5486a-16c0-4e69-8446-c50dd35163f1
        startup_shortcut = "C:\\Users\\#{user}\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\#{new_resource.name} - Shortcut.lnk"

        # ensure directory exists but
        # avoid windows + chef bug with inssuficient perms
        # http://stackoverflow.com/questions/17288107/chef-insufficient-permissions-creating-a-directory-in-c
        ruby_block "Create startup directory for #{user}" do
          block do
            FileUtils.mkdir_p "C:\\Users\\#{user}\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup"
          end
        end

        windows_shortcut startup_shortcut do
          target executable
          if elevate
            notifies :run, "execute[elevate #{new_resource.name} startup]", :immediate
          end
        end
        ammend_shortcut = "C:\\Windows\\Temp\\ammend_shortcut.vbs"
        execute "elevate #{new_resource.name} startup" do
          command "#{ammend_shortcut} #{startup_shortcut}"
          action :nothing
        end
      end

      action :delete do
        user = node[:windows_gui_service][:autologin][:user]
        executable = new_resource.executable
        elevate = new_resource.elevate
        # link for future boots
        # startup directory as in http://answers.microsoft.com/en-us/windows/forum/windows_7-system/how-to-get-startup-folder-in-start-all-programs/d3f5486a-16c0-4e69-8446-c50dd35163f1
        startup_shortcut = "C:\\Users\\#{user}\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\#{new_resource.name} - Shortcut.lnk"

        file startup_shortcut do
          action :delete
        end
      end
      
    end
  end
end
