
class RoleAccess < ActiveRecord::Base

	include BaseUtils
    audited :allow_mass_assignment => true
end
