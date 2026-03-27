class Organization::Position < ApplicationRecord
  belongs_to :organization
  belongs_to :department, class_name: "Organization::Department"
  belongs_to :updated_by, class_name: "User", optional: true
  belongs_to :reports_to, class_name: "Organization::Position", optional: true

  RATE_TYPE = %w[Hourly Salary].freeze
  JOB_TIER = ["Self", "Restaurant", "Above Restaurant", "Staff"].freeze
  AUTHORIZATION_LEVEL = %w[Position Location Department Organization].freeze
  JOB_CLASS = %w[Crew Management Supervision Staff].freeze

  AUTHORIZED =
    {
      user: { list: {access: false, organization: false, department: false, location: false},
        show: {access: false, organization: false, department: false, location: false},
        add: {access: false, organization: false, department: false, location: false},
        edit: {access: false, organization: false, department: false, location: false},
        remove: {access: false, organization: false, department: false, location: false}},
      organization: {
        organization: {Show: false},
        location: {List: false, Show: false, Add: false, Edit: false, Remove: false},
        department: {List: false, Show: false, Add: false, Edit: false, Remove: false},
        position: {List: false, Show: false, Add: false, Edit: false, Remove: false},
        reports: {List: false, Show: false, Add: false, Edit: false, Remove: false}},
      maintenance: {
        "equipment area" => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        "equipment type" => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        :equipment => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        :workorder => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        "workorder update" => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        :vendor => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        :supplier => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        "small parts" => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        :reports => {List: false, Show: false, Add: false, Edit: false, Remove: false}},
      comments: {
        :guest => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        :comment => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        "comments update" => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        :reports => {List: false, Show: false, Add: false, Edit: false, Remove: false}},
      recognition: {
        :recognition => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        :reward => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        "recognition type" => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        :reports => {List: false, Show: false, Add: false, Edit: false, Remove: false}},
      training: {
        curriculum: {List: false, Show: false, Add: false, Edit: false, Remove: false},
        class: {List: false, Show: false, Add: false, Edit: false, Remove: false},
        reports: {List: false, Show: false, Add: false, Edit: false, Remove: false}},
      onboarding: {
        "new hire" => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        :orientation => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        :reports => {List: false, Show: false, Add: false, Edit: false, Remove: false}},
      shops: {
        :oea => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        "service shop" => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        :reports => {List: false, Show: false, Add: false, Edit: false, Remove: false}},
      tracking: {
        :shift => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        "daily inventory" => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        :qcr => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        :reports => {List: false, Show: false, Add: false, Edit: false, Remove: false}},
      audits: {
        "food safety" => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        :safe => {List: false, Show: false, Add: false, Edit: false, Remove: false},
        :reports => {List: false, Show: false, Add: false, Edit: false, Remove: false}}
    }.freeze

end
