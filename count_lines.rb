total_lines = 0
Dir.glob("**/*.{rb,erb,css}") do |filename|
    file_lines = 0
    if !(File.directory?(filename) || filename == "count_lines.rb")
        f = File.open(filename, "r")
        lines = f.readlines
        lines.delete("\n")
        file_lines = lines.length
        puts "#{filename} has #{file_lines} lines of code"
        total_lines += file_lines
    end
end
puts "Total: #{total_lines} lines of code"
