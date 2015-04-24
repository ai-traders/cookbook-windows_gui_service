# windows_gui_service-cookbook

This cookbook solves a nasty Windows(>=7) problem of trying to run services that create some GUI elements. Usually you will encouter this problem
 * during automated GUI testing
 * when running continuous integration agent (like Jenkins) as a windows service
 * when trying to run old services/applications on new windows

## Solution

There are official, *correct* methods to deal with [windows session 0 isolation](https://msdn.microsoft.com/en-us/library/windows/hardware/dn653293%28v=vs.85%29.aspx). This cookbook provides alternative, when it is impossible or impractical to use IPC/ many processes, many users, etc.

General concept is to configure auto-login, then add shortcuts in windows autostart folder to processes which should run right after desktop starts.

Because of the auto-login **security is gone**. So do not use this cookbook in unsecure network.

## Supported Platforms

Windows 7 and above.

## Attributes

 * `node[:windows_gui_service][:autologin][:user]` - User to use for auto log-in. Default 'Admin'
 * `node[:windows_gui_service][:autologin][:password]` - Password of user to use for auto log-in. Default 'Admin'

## Usage

### Recipe windows_gui_service::default

Include `windows_gui_service` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[windows_gui_service::default]"
  ]
}
```
This will configure auto-login and install extra script needed by this cookbook to elevate shortcut permissions.

### Recipe windows_gui_service::autologin

Configures auto-login. Adds/updates user and password if missing. 
Requires attributes:
 * `node[:windows_gui_service][:autologin][:user]` - User to use for auto log-in. Default 'Admin'
 * `node[:windows_gui_service][:autologin][:password]` - Password of user to use for auto log-in. Default 'Admin'

### LWRP windows_gui_service

You can use `windows_gui_service` LWRP to add *services*.

The following properties are available
 * `executable` - string path to program or script to start. A shortcut to it will be created in autostart.
 * `elevate` - boolean, when true shortcut has 'Runs as Administrator' flag.

Examples

 * Start notepad after auto-login:

```ruby
include_recipe 'windows_gui_service::default'

windows_gui_service 'notepad' do
  executable 'C:/Windows/notepad.exe'
  action  :create
end
```

 * If you need to simulate 'Run As Administrator':

```ruby
include_recipe 'windows_gui_service::default'

windows_gui_service 'notepad' do
  executable 'C:/Windows/notepad.exe'
  action  :create
  elevate true
end
```

## Contributing

If you have better/another way of dealing with this then open an issue. Let's talk.
Pull requests welcome.

## License and Authors

Author:: Tomasz Setkowski (<tom@ai-traders.com>)
