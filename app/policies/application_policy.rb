class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  protected

  def manager?
    inventory_user&.manager?
  end

  def item_administrator?
    inventory_user&.item_administrator?
  end

  def viewer?
    inventory_user&.viewer?
  end

  def inventory_user
    @inventory_user ||= begin
      inventory = if record.respond_to?(:inventory)
        record.inventory
      elsif record.is_a?(Inventory)
        record
      end
      
      inventory&.inventory_users&.find_by(user: user)
    end
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end