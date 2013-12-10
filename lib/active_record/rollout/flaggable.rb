module ActiveRecord::Rollout::Flaggable
  # Returns whether or not the object has access to the given feature. If given
  # a block, it will call the block if the user has access to the feature.
  #
  # If an exception is raised in the block, it will increment the
  # `failure_count` of the feature and raise the exception.
  #
  # @example
  #   # Exceptions will be tracked in the `failure_count` of :new_user_interface.
  #   user.has_feature?(:new_user_interface) do
  #     # ...
  #   end
  #
  # @example
  #   # Exceptions will *not* be tracked in the `failure_count` of :new_user_interface.
  #   if user.has_feature?(:new_user_interface)
  #     # ...
  #   end
  #
  # @param [Symbol] feature_name The name of the
  #   {ActiveRecord::Rollout::Feature Feature} being checked.
  # @param [Proc] &block A block to be called if the user is flagged in to the
  #   feature.
  def has_feature?(feature_name, &block)
    feature = ActiveRecord::Rollout::Feature.find_by_name(feature_name)
    return false unless feature

    opt_out = opt_out_flags.find_by_feature_id(feature.id)
    return false if opt_out

    match = feature.match? self

    if match && block_given?
      begin
        yield
      rescue => e
        feature.increment! :failure_count
        raise e
      end
    end

    match
  end
end
