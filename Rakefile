ports = [4567,4568]
desc "Start the app server"
task :start => :stop do
	puts "Starting the blog"
	system "bin/thin start -e production -s 2 -C config/config.yml -R config/rackup.ru"
end

# code lifted from rush
def process_alive(pid)
	::Process.kill(0, pid)
	true
rescue Errno::ESRCH
	false
end

def kill_process(pid)
	::Process.kill('TERM', pid)

	5.times do
		return if !process_alive(pid)
		sleep 0.5
		::Process.kill('TERM', pid) rescue nil
	end

	::Process.kill('KILL', pid) rescue nil
rescue Errno::ESRCH
end

desc "Stop the app server"
task :stop do  
  ports.each do |port|
    m = `netstat -lptn | grep 127.0.0.1:#{port}`.match(/LISTEN\s*(\d+)/)
    if m
      pid = m[1].to_i
      puts "Killing old server #{pid}"
      kill_process(pid)
    end
  end
end
