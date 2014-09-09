
# Tailor
guard 'shell' do
  watch(%r{.tailor$})
  # All *file -configuration files (Vagrantfile, Guardfile, etc.)
  watch(%r{(.+file)$}) { |m| system('tailor #{m[0]}') }
end
