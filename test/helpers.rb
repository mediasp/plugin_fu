require 'minitest/autorun'
require 'plugin_fu'
require 'open4'

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

  def assert_stderr_matches(pattern_or_string)
    pattern = pattern_or_string.is_a?(Regexp) ? pattern_or_string :
      Regexp.new(Regexp.escape(pattern_or_string))

    assert pattern.match(@last_stderr), "#{pattern} not in #@last_stderr"
  end

  def assert_stdout_matches(pattern_or_string)
    pattern = pattern_or_string.is_a?(Regexp) ? pattern_or_string :
      Regexp.new(Regexp.escape(pattern_or_string))

    assert pattern.match(@last_stdout), "#{pattern} not in #@last_stdout"
  end
end
