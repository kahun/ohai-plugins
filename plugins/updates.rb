#
# Author:: Francisco Augusto
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

Ohai.plugin(:Updates) do
  provides 'packages_updates'
  depends'platform_family'

  collect_data(:linux) do
    packages_updates Mash.new

    if platform_family.eql?("debian")
      so = shell_out("aptitude -F'%p %v %V' --disable-columns search ~U")
      pkgs = so.stdout.split("\n")
      pkgs.each do |pkg|
        pkg = pkg.split(" ")
        packages_updates[pkg[0]] = {"installed" => pkg[1], "candidate" => pkg[2]}
      end
    end
  end
end
