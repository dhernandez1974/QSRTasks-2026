Admin.find_or_create_by!(email: 'admin@qsrtasks.com') do |admin|
  admin.password = 'mina1973'
  admin.password_confirmation = 'mina1973'
  admin.first_name = 'Daniel'
  admin.last_name = 'Hernandez'
end

Organization.find_or_create_by!(eid: 'ef002032') do |org|
  org.name = 'Stagg Restaurants Partnership'
  org.phone = '210-375-7100'
  org.street = '8507 Speedway Drive'
  org.city = 'San Antonio'
  org.state = 'TX'
  org.zip = '78230'
  org.primary_operator = true
  org.primary_eid = 'ef002032'
end

Organization.find_or_create_by!(eid: 'e0071374') do |org|
  org.name = 'Stagg Restaurants Partnership II'
  org.phone = '210-375-7100'
  org.street = '8507 Speedway Drive'
  org.city = 'San Antonio'
  org.state = 'TX'
  org.zip = '78230'
  org.primary_operator = false
  org.primary_eid = 'ef002032'
end

stagg = Organization.find_by(eid: 'ef002032')
puts "Creating Locations"

Location.find_or_create_by!(number: 1480) do |loc|
  loc.name = 'South Laredo'
  loc.street = '1330 S. Laredo St'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78207'
  loc.email = 'hou.01480@us.stores.mcd.com'
  loc.phone = '1-210-226-6740'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 1703) do |loc|
  loc.name = 'SW Military'
  loc.street = '2135 SW Military'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78224'
  loc.email = 'hou.01703@us.stores.mcd.com'
  loc.phone = '1-210-924-7379'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 1725) do |loc|
  loc.name = 'San Pedro'
  loc.street = '6967 San Pedro'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78237'
  loc.email = 'hou.01725@us.stores.mcd.com'
  loc.phone = '1-210-342-6811'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 2962) do |loc|
  loc.name = 'West Commerce'
  loc.street = '4422 W. Commerce Street'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78237'
  loc.email = 'hou.02962@us.stores.mcd.com'
  loc.phone = '1-210-438-5020'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 3348) do |loc|
  loc.name = 'Southcross'
  loc.street = '2402 E. Southcross Blvd'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78223'
  loc.email = 'hou.03348@us.stores.mcd.com'
  loc.phone = '1-210-533-8771'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 3447) do |loc|
  loc.name = 'Wurzbach'
  loc.street = '9600 I-10 NW'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78230'
  loc.email = 'hou.03447@us.stores.mcd.com'
  loc.phone = '1-210-593-0344'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 5166) do |loc|
  loc.name = 'WW White'
  loc.street = '102 S WW White Rd'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78219'
  loc.email = 'hou.05166@us.stores.mcd.com'
  loc.phone = '1-210-337-4571'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 5623) do |loc|
  loc.name = 'Roosevelt'
  loc.street = '3502 SW Military Drive'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78223'
  loc.email = 'hou.05623@us.stores.mcd.com'
  loc.phone = '1-210-927-5273'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 5984) do |loc|
  loc.name = 'Walters'
  loc.street = '100 Walters'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78222'
  loc.email = 'dal.05984@us.stores.mcd.com'
  loc.phone = '210-777-7770'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 6661) do |loc|
  loc.name = 'Hill Country'
  loc.street = '15715 San Pedro'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78232'
  loc.email = 'hou.06661@us.stores.mcd.com'
  loc.phone = '1-210-496-1294'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 7091) do |loc|
  loc.name = 'West Houston'
  loc.street = '703 West Houston'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78207'
  loc.email = 'hou.07091@us.stores.mcd.com'
  loc.phone = '(1-210-271-3565'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 7850) do |loc|
  loc.name = 'Med Center'
  loc.street = '7267 Wurzbach'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78229'
  loc.email = 'hou.07850@us.stores.mcd.com'
  loc.phone = '1-210-692-9886'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 10271) do |loc|
  loc.name = 'New Braunfels'
  loc.street = '1000 New Braunfels'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78222'
  loc.email = 'dal.10271@us.stores.mcd.com'
  loc.phone = '1-210-777-7772'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 10586) do |loc|
  loc.name = 'Vance Jackson'
  loc.street = '4331 vance Jackson'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78230'
  loc.email = 'hou.10586@us.stores.mcd.com'
  loc.phone = '1-210-341-7886'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 10675) do |loc|
  loc.name = 'Guilbeau'
  loc.street = '7663 Guilbeau Rd'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78250'
  loc.email = 'hou.10675@us.stores.mcd.com'
  loc.phone = '(210) 647-3588'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 10999) do |loc|
  loc.name = 'Pleasanton'
  loc.street = '7663 Guilbeau Rd'
  loc.city = 'Pleasanton'
  loc.state = 'TX'
  loc.zip = '78250'
  loc.email = 'dal.10999@us.stores.mcd.com'
  loc.phone = '(210) 647-3598'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 11966) do |loc|
  loc.name = 'Schertz'
  loc.street = '1111 Schertz'
  loc.city = 'Schertz'
  loc.state = 'TX'
  loc.zip = '78222'
  loc.email = 'dal.11966@us.stores.mcd.com'
  loc.phone = '1-210-777-7773'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 12673) do |loc|
  loc.name = 'DeZavala'
  loc.street = '5235 DeZavala'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78249'
  loc.email = 'hou.12673@us.stores.mcd.com'
  loc.phone = '1-210-696-1659'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 13364) do |loc|
  loc.name = 'Zarzamora'
  loc.street = '826 S. Zarzamora'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78207'
  loc.email = 'hou.13364@us.stores.mcd.com'
  loc.phone = '1-210-438-1696'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 14073) do |loc|
  loc.name = 'Broadway'
  loc.street = '8631 Broadway'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78209'
  loc.email = 'hou.14073@us.stores.mcd.com'
  loc.phone = '1-210-822-4714'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 17726) do |loc|
  loc.name = 'Rigsby'
  loc.street = '5304 Rigsby'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78222'
  loc.email = 'hou.17726@us.stores.mcd.com'
  loc.phone = '1-210-333-3444'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 19116) do |loc|
  loc.name = 'Babcock & Prue'
  loc.street = '6370 Babcock'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78209'
  loc.email = 'hou.19116@us.stores.mcd.com'
  loc.phone = '1-210-558-4588'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 19174) do |loc|
  loc.name = 'Foster & 78'
  loc.street = '777 Foster'
  loc.city = 'Converse'
  loc.state = 'TX'
  loc.zip = '78222'
  loc.email = 'dal.19174@us.stores.mcd.com'
  loc.phone = '1-210-777-7774'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 22796) do |loc|
  loc.name = "O'Conner"
  loc.street = '11710 I-35 North'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78233'
  loc.email = 'hou.22796@us.stores.mcd.com'
  loc.phone = '1-210-637-1611'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 23005) do |loc|
  loc.name = 'Floresville'
  loc.street = '530 Tenth Street'
  loc.city = 'Floresville'
  loc.state = 'TX'
  loc.zip = '78114'
  loc.email = 'hou.23005@us.stores.mcd.com'
  loc.phone = '1-830-393-9393'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 24388) do |loc|
  loc.name = 'Converse'
  loc.street = '9151 FM 78'
  loc.city = 'Converse'
  loc.state = 'TX'
  loc.zip = '78109'
  loc.email = 'hou.24388@us.stores.mcd.com'
  loc.phone = '1-210-566-9922'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 26150) do |loc|
  loc.name = 'Stonecroft'
  loc.street = '11611 Bandera Road'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78250'
  loc.email = 'hou.26150@us.stores.mcd.com'
  loc.phone = '1-210-521-2095'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 28656) do |loc|
  loc.name = 'Ralph Fair'
  loc.street = '25200 I-10 West Lot 2'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78257'
  loc.email = 'hou.28656@us.stores.mcd.com'
  loc.phone = '1-210-687-1232'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 30464) do |loc|
  loc.name = '1604/281 STO'
  loc.street = '7663 Guilbeau Rd'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78250'
  loc.email = 'dal.30464@us.stores.mcd.com'
  loc.phone = '(210) 647-3688'
  loc.safe_count = 2000
  loc.ipad_count = 2
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 31024) do |loc|
  loc.name = 'SW Military WM'
  loc.street = '7663 Guilbeau Rd'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78250'
  loc.email = 'dal.31024@us.stores.mcd.com'
  loc.phone = '(210) 637-3588'
  loc.safe_count = 1500
  loc.ipad_count = 2
  loc.headset_count = 0
  loc.location_type = 'WM'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 32872) do |loc|
  loc.name = 'Somerset'
  loc.street = '3231 SW Military'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78211'
  loc.email = 'hou.32872@us.stores.mcd.com'
  loc.phone = '(210) 924-1884'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 34798) do |loc|
  loc.name = 'The Rim'
  loc.street = '18503 IH 10 W'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78257'
  loc.email = 'hou.34798@us.stores.mcd.com'
  loc.phone = '1-210-561-9900'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 35416) do |loc|
  loc.name = 'Comfort'
  loc.street = '43 US Highway 87 Ste M'
  loc.city = 'Comfort'
  loc.state = 'TX'
  loc.zip = '78013'
  loc.email = 'hou.35416@us.stores.mcd.com'
  loc.phone = '1-830-995-5621'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 38841) do |loc|
  loc.name = 'Palo Alto'
  loc.street = '111 Palo Alto'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78222'
  loc.email = "dal.38841@us.stores.mcd.com"
  loc.phone = '1-210-251-4440'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 39510) do |loc|
  loc.name = 'Foster Rd'
  loc.street = '1852 North Foster Road'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78244'
  loc.email = "dal.39510@us.stores.mcd.com"
  loc.phone = '1-210-999-3732'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 39616) do |loc|
  loc.name = '37 South'
  loc.street = '20303 I-37 South'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78264'
  loc.email = "dal.39616@us.stores.mcd.com"
  loc.phone = '1-210-760-6462'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 43197) do |loc|
  loc.name = 'Binz Engleman'
  loc.street = '5439 Fm 1516 North'
  loc.city = 'Converse'
  loc.state = 'TX'
  loc.zip = '78109'
  loc.email = "dal.43197@us.stores.mcd.com"
  loc.phone = '1-210-555-6462'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 43112) do |loc|
  loc.name = 'Tarpon Road'
  loc.street = '28409 I-10 West'
  loc.city = 'Boerne'
  loc.state = 'TX'
  loc.zip = '78006'
  loc.email = "dal.43112@us.stores.mcd.com"
  loc.phone = '1-210-555-5462'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 39958) do |loc|
  loc.name = 'La Vernia'
  loc.street = '111 La Vernia'
  loc.city = 'La Vernia'
  loc.state = 'TX'
  loc.zip = '78111'
  loc.email = "dal.39958@us.stores.mcd.com"
  loc.phone = '1-830-777-7777'
  loc.safe_count = 2000
  loc.ipad_count = 3
  loc.headset_count = 7
  loc.location_type = 'Traditional'
  loc.organization_id = stagg.id
end

Location.find_or_create_by!(number: 9) do |loc|
  loc.name = 'Office'
  loc.street = '8507 Speedway Drive'
  loc.city = 'San Antonio'
  loc.state = 'TX'
  loc.zip = '78230'
  loc.email = 'office@staggrp.com'
  loc.phone = '1-210-375-7100'
  loc.safe_count = 0
  loc.ipad_count = 0
  loc.headset_count = 0
  loc.location_type = 'Office'
  loc.organization_id = stagg.id
end
