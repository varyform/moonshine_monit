module Monit

  # Define options for this plugin via the <tt>configure</tt> method
  # in your application manifest:
  #
  #   configure(:monit => {:foo => true})
  #
  # Then include the plugin and call the recipe(s) you need:
  #
  #  plugin :monit
  #  recipe :monit
  def monit(options = {})
    package 'monit', :ensure => :installed

    file '/etc/monit/monitrc',
      :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'monitrc'), binding),
      :mode => '600',
      :owner => 'root',
      :group => 'root',
      :require => package('monit'),
      :before => service('monit'),
      :notify => service('monit')

    file '/etc/monit/conf.d',
      :ensure => :directory,
      :mode   => '755',
      :owner =>  'root',
      :group =>  'root',
      :before => service("monit")

    file '/etc/monit/conf.d/apache',
      :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'apache'), binding),
      :mode => '600',
      :owner =>  'root',
      :group =>  'root',
      :require => file('/etc/monit/conf.d')

    file '/etc/default/monit',
      :content => template(File.join(File.dirname(__FILE__), '..', 'templates', 'startup')),
      :mode => '644',
      :owner =>  'root',
      :group =>  'root',
      :before => service("monit")

    file '/etc/init.d/monit',
      :mode => '755',
      :owner =>  'root',
      :group =>  'root',
      :before => service("monit")

    exec 'restart_monit',
      :command => 'monit reload',
      :require => file('/etc/init.d/monit'),
      :refreshonly => true

    service 'monit',
      :require => package('monit'),
      :enable => true,
      :ensure => :running
  end

end
