module ApplicationHelper
  def us_states
    [
      ['Alabama', 'AL'],
      ['Alaska', 'AK'],
      ['Arizona', 'AZ'],
      ['Arkansas', 'AR'],
      ['California', 'CA'],
      ['Colorado', 'CO'],
      ['Connecticut', 'CT'],
      ['Delaware', 'DE'],
      ['District of Columbia', 'DC'],
      ['Florida', 'FL'],
      ['Georgia', 'GA'],
      ['Hawaii', 'HI'],
      ['Idaho', 'ID'],
      ['Illinois', 'IL'],
      ['Indiana', 'IN'],
      ['Iowa', 'IA'],
      ['Kansas', 'KS'],
      ['Kentucky', 'KY'],
      ['Louisiana', 'LA'],
      ['Maine', 'ME'],
      ['Maryland', 'MD'],
      ['Massachusetts', 'MA'],
      ['Michigan', 'MI'],
      ['Minnesota', 'MN'],
      ['Mississippi', 'MS'],
      ['Missouri', 'MO'],
      ['Montana', 'MT'],
      ['Nebraska', 'NE'],
      ['Nevada', 'NV'],
      ['New Hampshire', 'NH'],
      ['New Jersey', 'NJ'],
      ['New Mexico', 'NM'],
      ['New York', 'NY'],
      ['North Carolina', 'NC'],
      ['North Dakota', 'ND'],
      ['Ohio', 'OH'],
      ['Oklahoma', 'OK'],
      ['Oregon', 'OR'],
      ['Pennsylvania', 'PA'],
      ['Puerto Rico', 'PR'],
      ['Rhode Island', 'RI'],
      ['South Carolina', 'SC'],
      ['South Dakota', 'SD'],
      ['Tennessee', 'TN'],
      ['Texas', 'TX'],
      ['Utah', 'UT'],
      ['Vermont', 'VT'],
      ['Virginia', 'VA'],
      ['Washington', 'WA'],
      ['West Virginia', 'WV'],
      ['Wisconsin', 'WI'],
      ['Wyoming', 'WY']
    ]
  end

  def initialize_new_contact_form
    return if content_for?(:new_contact_form)
    @contact = Contact.new
    content_for :new_contact_form, render("contacts/ajax_form")
  end

  def contact_select_with_create_new(form, name, contacts, html_options = {})
    initialize_new_contact_form
    select_options = contacts ? contacts.collect { |s| [s.id, s.name, class: "contact-item"] }.prepend([]) : []
    select_options << [ "create_new_contact", "Create New Contact", class: "create-new"]

    local_options = {
      'data-placeholder': 'Choose Contacts...',
      class: 'chosen-select add-new-contactable',
      multiple: true,
      onchange: "handleSelectOnChange(this);"
    }.merge(html_options)

    form.collection_select(name, select_options,
                           :first, :second, {}, local_options)
  end

  def shared_category_view_path(category,user)
    case category.name
    when 'Wills - Trusts - Legal'
      shared_view_estate_planning_path(user)
    when 'Insurance'
      shared_view_insurance_path(user)
    when 'Taxes'
      shared_view_taxes_path(user)
    when 'Final Wishes'
      shared_view_final_wishes_path(user)
    when 'Financial Information'
      shared_view_financial_information_path(user)
    else
     shared_view_dashboard_path(user) 
    end
  end
end
