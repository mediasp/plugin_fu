module ExecHelper
  def popen3(cmd)
    @last_command = cmd

    @last_status = Open4.popen4(@last_command) do |pid, stdin, stdout, stderr|
      @last_stdout = stdout.read.strip
      @last_stderr = stderr.read.strip
    end
  end

  def last_run
    {
      :command => @last_command,
      :stdout  => @last_stdout,
      :stderr  => @last_stderr,
      :status  => @last_status
    }
  end

  def exec(cmd)
    popen3(cmd)
    if @last_status.exitstatus != 0
      raise "command: #{cmd} failed with #{@last_status.exitstatus}\n#{@all_output}"
    end
    true
  end

  def all_output
    @last_stdout + "\n" + @last_stderr
  end
end
