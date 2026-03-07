Admin.create!(email: 'admin@qsrtasks.com', password: 'mina1973', password_confirmation: 'mina1973', first_name:
  'Daniel', last_name: 'Hernandez')

Organization.create!(name: 'Stagg Restaurants Partnership', phone: '210-375-7100', eid: 'ef002032',
  street: '8507 Speedway Drive', city: 'San Antonio', state: 'TX', zip: '78230',
  primary_operator: true, primary_eid: 'ef002032')

Organization.create!(name: 'Stagg Restaurants Partnership II', phone: '210-375-7100', eid: 'e0071374',
  street: '8507 Speedway Drive', city: 'San Antonio', state: 'TX', zip: '78230',
  primary_operator: false, primary_eid: 'ef002032')

stagg = Organization.find_by(eid: 'ef002032')
puts "Creating Locations"

Location.create(number: 1480, name: 'South Laredo', street: '1330 S. Laredo St', city: 'San Antonio',
  state: 'TX', zip: '78207', email: 'hou.01480@us.stores.mcd.com', phone: '1-210-226-6740',
  safe_count: 2000, ipad_count: 3, headset_count: 7, location_type: 'Traditional',
  organization_id: stagg.id)

Location.create(number: 1703, name: 'SW Military', street: '2135 SW Military', city: 'San Antonio',
  state: 'TX', zip: '78224', email: 'hou.01703@us.stores.mcd.com', phone: '1-210-924-7379',
  safe_count: 2000, ipad_count: 3, headset_count: 7, location_type: 'Traditional',
  organization_id: stagg.id)

Location.create(number: 1725, name: 'San Pedro', street: '6967 San Pedro', city: 'San Antonio', state: 'TX',
  zip: '78237', email: 'hou.01725@us.stores.mcd.com', phone: '1-210-342-6811', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 2962, name: 'West Commerce', street: '4422 W. Commerce Street', city: 'San Antonio',
  state: 'TX', zip: '78237', email: 'hou.02962@us.stores.mcd.com', phone: '1-210-438-5020',
  safe_count: 2000, ipad_count: 3, headset_count: 7, location_type: 'Traditional',
  organization_id: stagg.id)

Location.create(number: 3348, name: 'Southcross', street: '2402 E. Southcross Blvd', city: 'San Antonio',
  state: 'TX', zip: '78223', email: 'hou.03348@us.stores.mcd.com', phone: '1-210-533-8771',
  safe_count: 2000, ipad_count: 3, headset_count: 7, location_type: 'Traditional',
  organization_id: stagg.id)

Location.create(number: 3447, name: 'Wurzbach', street: '9600 I-10 NW', city: 'San Antonio', state: 'TX',
  zip: '78230', email: 'hou.03447@us.stores.mcd.com', phone: '1-210-593-0344', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 5166, name: 'WW White', street: '102 S WW White Rd', city: 'San Antonio', state: 'TX',
  zip: '78219', email: 'hou.05166@us.stores.mcd.com', phone: '1-210-337-4571', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 5623, name: 'Roosevelt', street: '3502 SW Military Drive', city: 'San Antonio',
  state: 'TX', zip: '78223', email: 'hou.05623@us.stores.mcd.com', phone: '1-210-927-5273',
  safe_count: 2000, ipad_count: 3, headset_count: 7, location_type: 'Traditional',
  organization_id: stagg.id)

Location.create(number: 5984, name: 'Walters', street: '100 Walters', city: 'San Antonio', state: 'TX',
  zip: '78222', email: 'dal.05984@us.stores.mcd.com', phone: '210-777-7770', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 6661, name: 'Hill Country', street: '15715 San Pedro', city: 'San Antonio',
  state: 'TX', zip: '78232', email: 'hou.06661@us.stores.mcd.com', phone: '1-210-496-1294',
  safe_count: 2000, ipad_count: 3, headset_count: 7, location_type: 'Traditional',
  organization_id: stagg.id)

Location.create(number: 7091, name: 'West Houston', street: '703 West Houston', city: 'San Antonio',
  state: 'TX', zip: '78207', email: 'hou.07091@us.stores.mcd.com', phone: '(1-210-271-3565',
  safe_count: 2000, ipad_count: 3, headset_count: 7, location_type: 'Traditional',
  organization_id: stagg.id)

Location.create(number: 7850, name: 'Med Center', street: '7267 Wurzbach', city: 'San Antonio', state: 'TX',
  zip: '78229', email: 'hou.07850@us.stores.mcd.com', phone: '1-210-692-9886', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 10271, name: 'New Braunfels', street: '1000 New Braunfels', city: 'San Antonio',
  state: 'TX', zip: '78222', email: 'dal.10271@us.stores.mcd.com', phone: '1-210-777-7772',
  safe_count: 2000, ipad_count: 3, headset_count: 7, location_type: 'Traditional',
  organization_id: stagg.id)

Location.create(number: 10586, name: 'Vance Jackson', street: '4331 vance Jackson', city: 'San Antonio',
  state: 'TX', zip: '78230', email: 'hou.10586@us.stores.mcd.com', phone: '1-210-341-7886',
  safe_count: 2000, ipad_count: 3, headset_count: 7, location_type: 'Traditional',
  organization_id: stagg.id)

Location.create(number: 10675, name: 'Guilbeau', street: '7663 Guilbeau Rd', city: 'San Antonio', state: 'TX',
  zip: '78250', email: 'hou.10675@us.stores.mcd.com', phone: '(210) 647-3588', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 10999, name: 'Pleasanton', street: '7663 Guilbeau Rd', city: 'Pleasanton', state:
  'TX', zip: '78250', email: 'dal.10999@us.stores.mcd.com', phone: '(210) 647-3598', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 11966, name: 'Schertz', street: '1111 Schertz', city: 'Schertz', state: 'TX',
  zip: '78222', email: 'dal.11966@us.stores.mcd.com', phone: '1-210-777-7773', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 12673, name: 'DeZavala', street: '5235 DeZavala', city: 'San Antonio', state: 'TX',
  zip: '78249', email: 'hou.12673@us.stores.mcd.com', phone: '1-210-696-1659', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 13364, name: 'Zarzamora', street: '826 S. Zarzamora', city: 'San Antonio', state: 'TX',
  zip: '78207', email: 'hou.13364@us.stores.mcd.com', phone: '1-210-438-1696', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 14073, name: 'Broadway', street: '8631 Broadway', city: 'San Antonio', state: 'TX',
  zip: '78209', email: 'hou.14073@us.stores.mcd.com', phone: '1-210-822-4714', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 17726, name: 'Rigsby', street: '5304 Rigsby', city: 'San Antonio', state: 'TX',
  zip: '78222', email: 'hou.17726@us.stores.mcd.com', phone: '1-210-333-3444', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 19116, name: 'Babcock & Prue', street: '6370 Babcock', city: 'San Antonio',
  state: 'TX', zip: '78209', email: 'hou.19116@us.stores.mcd.com', phone: '1-210-558-4588',
  safe_count: 2000, ipad_count: 3, headset_count: 7, location_type: 'Traditional',
  organization_id: stagg.id)

Location.create(number: 19174, name: 'Foster & 78', street: '777 Foster', city: 'Converse', state: 'TX',
  zip: '78222', email: 'dal.19174@us.stores.mcd.com', phone: '1-210-777-7774', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 22796, name: "O'Conner", street: '11710 I-35 North', city: 'San Antonio', state: 'TX',
  zip: '78233', email: 'hou.22796@us.stores.mcd.com', phone: '1-210-637-1611', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 23005, name: 'Floresville', street: '530 Tenth Street', city: 'Floresville',
  state: 'TX', zip: '78114', email: 'hou.23005@us.stores.mcd.com', phone: '1-830-393-9393',
  safe_count: 2000, ipad_count: 3, headset_count: 7, location_type: 'Traditional',
  organization_id: stagg.id)

Location.create(number: 24388, name: 'Converse', street: '9151 FM 78', city: 'Converse', state: 'TX',
  zip: '78109', email: 'hou.24388@us.stores.mcd.com', phone: '1-210-566-9922', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 26150, name: 'Stonecroft', street: '11611 Bandera Road', city: 'San Antonio',
  state: 'TX', zip: '78250', email: 'hou.26150@us.stores.mcd.com', phone: '1-210-521-2095',
  safe_count: 2000, ipad_count: 3, headset_count: 7, location_type: 'Traditional',
  organization_id: stagg.id)

Location.create(number: 28656, name: 'Ralph Fair', street: '25200 I-10 West Lot 2', city: 'San Antonio',
  state: 'TX', zip: '78257', email: 'hou.28656@us.stores.mcd.com', phone: '1-210-687-1232',
  safe_count: 2000, ipad_count: 3, headset_count: 7, location_type: 'Traditional',
  organization_id: stagg.id)

Location.create(number: 30464, name: '1604/281 STO', street: '7663 Guilbeau Rd', city: 'San Antonio', state:
  'TX', zip: '78250', email: 'dal.30464@us.stores.mcd.com', phone: '(210) 647-3688', safe_count: 2000,
  ipad_count: 2, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 31024, name: 'SW Military WM', street: '7663 Guilbeau Rd', city: 'San Antonio', state:
  'TX', zip: '78250', email: 'dal.31024@us.stores.mcd.com', phone: '(210) 637-3588', safe_count: 1500,
  ipad_count: 2, headset_count: 0, location_type: 'WM', organization_id: stagg.id)

Location.create(number: 32872, name: 'Somerset', street: '3231 SW Military', city: 'San Antonio', state: 'TX',
  zip: '78211', email: 'hou.32872@us.stores.mcd.com', phone: '(210) 924-1884', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 34798, name: 'The Rim', street: '18503 IH 10 W', city: 'San Antonio', state: 'TX',
  zip: '78257', email: 'hou.34798@us.stores.mcd.com', phone: '1-210-561-9900', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 35416, name: 'Comfort', street: '43 US Highway 87 Ste M', city: 'Comfort', state: 'TX',
  zip: '78013', email: 'hou.35416@us.stores.mcd.com', phone: '1-830-995-5621', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 38841, name: 'Palo Alto', street: '111 Palo Alto', city: 'San Antonio', state: 'TX',
  zip: '78222', email: "dal.38841@us.stores.mcd.com", phone: '1-210-251-4440', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 39510, name: 'Foster Rd', street: '1852 North Foster Road', city: 'San Antonio',
  state: 'TX', zip: '78244', email: "dal.39510@us.stores.mcd.com", phone: '1-210-999-3732',
  safe_count: 2000, ipad_count: 3, headset_count: 7, location_type: 'Traditional',
  organization_id: stagg.id)

Location.create(number: 39616, name: '37 South', street: '20303 I-37 South', city: 'San Antonio', state:
  'TX', zip: '78264', email: "dal.39616@us.stores.mcd.com", phone: '1-210-760-6462', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 43197, name: 'Binz Engleman', street: '5439 Fm 1516 North', city: 'Converse', state:
  'TX', zip: '78109', email: "dal.43197@us.stores.mcd.com", phone: '1-210-555-6462', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 43112, name: 'Tarpon Road', street: '28409 I-10 West', city: 'Boerne', state:
  'TX', zip: '78006', email: "dal.43112@us.stores.mcd.com", phone: '1-210-555-5462', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(number: 39958, name: 'La Vernia', street: '111 La Vernia', city: 'La Vernia', state: 'TX',
  zip: '78111', email: "dal.39958@us.stores.mcd.com", phone: '1-830-777-7777', safe_count: 2000,
  ipad_count: 3, headset_count: 7, location_type: 'Traditional', organization_id: stagg.id)

Location.create(name: 'Office', number: 9, street: '8507 Speedway Drive', city: 'San Antonio', state: 'TX',
  zip: '78230', email: 'office@staggrp.com', phone: '1-210-375-7100', safe_count: 0, ipad_count: 0,
  headset_count: 0, location_type: 'Office', organization_id: stagg.id)
