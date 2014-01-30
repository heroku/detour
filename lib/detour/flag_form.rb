class Detour::FlagForm
  def initialize(flaggable_type)
    @flaggable_type = flaggable_type
  end

  def features
    @features ||= Detour::Feature.includes("#{@flaggable_type}_percentage_flag", "#{@flaggable_type}_database_group_flags", "#{@flaggable_type}_defined_group_flags").with_lines
  end

  def errors?
    features.any? { |feature| feature.errors.any? }
  end

  def database_groups
    Detour::Group.where(flaggable_type: @flaggable_type.singularize.capitalize)
  end

  def group_names
    @group_names ||= begin
      all_names = features.collect { |feature| feature.send("#{@flaggable_type}_defined_group_flags").collect(&:group_name) }.uniq.flatten
      (all_names | Detour::DefinedGroup.by_type(@flaggable_type).map(&:name)).sort
    end
  end

  def defined_group_flags_for(feature)
    group_names.map do |group_name|
      flags = feature.send("#{@flaggable_type}_defined_group_flags")
      flags.detect { |flag| flag.group_name == group_name } || flags.new(group_name: group_name)
    end
  end

  def database_group_flags_for(feature)
    database_groups.map do |group|
      flags = feature.send("#{@flaggable_type}_database_group_flags")
      flags.detect { |flag| flag.group.id == group.id } || (flags.new(group_id: group.id))
    end
  end

  def update_attributes(params)
    Detour::Feature.transaction do |transaction|
      features.map do |feature|
        feature_params = params[:features][feature.name]
        next unless feature_params

        check_percentage_flag_for_deletion(feature, feature_params)
        process_defined_group_flags(feature, feature_params)
        set_database_group_flag_params(feature, feature_params)

        feature.assign_attributes feature_params
        feature.save if feature.changed_for_autosave?
      end

      if features.any? { |feature| feature.errors.any? }
        raise ActiveRecord::Rollback
      else
        true
      end
    end
  end

  private

  def check_percentage_flag_for_deletion(feature, params)
    key         = :"#{@flaggable_type}_percentage_flag_attributes"
    flag        = feature.send("#{@flaggable_type}_percentage_flag")
    flag_params = params[key]

    if flag.present? && flag_params[:percentage].blank?
      feature.send("#{@flaggable_type}_percentage_flag").mark_for_destruction
      feature.send("#{@flaggable_type}_percentage_flag=", nil)
    end

    if flag.present? && flag_params[:percentage].to_i == flag.percentage
      params.delete key
    end
  end

  def process_defined_group_flags(feature, params)
    key          = :"#{@flaggable_type}_defined_group_flags_attributes"
    flags_params = params[key] || {}
    params.delete key

    defined_group_flags_for(feature).each do |flag|
      flag.keep_or_destroy(flags_params[flag.group_name])
    end
  end

  def set_database_group_flag_params(feature, params)
    key          = :"#{@flaggable_type}_database_group_flags_attributes"
    flags_params = params[key] || {}
    params.delete key

    database_groups.zip(database_group_flags_for(feature)).each do |group, flag|
      flag_params = flags_params[group.name] || {}
      to_keep     = flag_params["to_keep"] == "1"
      flags_params.delete group.name

      if flag && to_keep
        flag.to_keep = true
      elsif flag && !to_keep
        flag.mark_for_destruction
      elsif !flag && to_keep
        flag = feature.send("#{@flaggable_type}_database_group_flags").new group_id: group.id
        flag.to_keep = true
      end
    end
  end
end
