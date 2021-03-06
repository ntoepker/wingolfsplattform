module EventsHelper
  
  def group_to_create_the_event_for
    @group || first_group_the_current_user_can_create_events_for
  end
  
  def groups_the_current_user_can_create_events_for
    current_user.groups.find_all_by_flag(:officers_parent).collect { |op| op.parent_groups.first }
  end

  def first_group_the_current_user_can_create_events_for
    current_user.groups.find_all_by_flag(:officers_parent).first.try(:parent_groups).try(:first)
  end
  
  def title_for_events_index
    return t :my_events if @navable == current_user
    return t :events_on_global_website if @on_global_website
    return t :events_on_local_website if @on_local_website
    return "#{t(:events_of)} '#{@group.name}'" if @group
    return t :all_events if @all
    return t :events
  end
  
end