class VaultEntriesController < AuthenticatedController
  before_action :set_vault_entry, only: [:show, :edit, :update, :destroy]

  def index
    @vault_entries = VaultEntry.all
  end

  def show
  end

  def new
    @vault_entry = VaultEntryBuilder.new.build
    @vault_entry.vault_entry_contacts.build
    @vault_entry.vault_entry_beneficiaries.build
  end

  def create
    adjusted_params = vault_entry_params.merge(user_id: current_user.id)
    @vault_entry = VaultEntryBuilder.new(adjusted_params).build

    respond_to do |format|
      if @vault_entry.save
        format.html { redirect_to estate_planning_path, notice: 'Vault entry was successfully created.' }
        format.json { render :show, status: :created, location: @vault_entry }
      else
        format.html { render :new }
        format.json { render json: @vault_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_vault_entry
      @vault_entry = VaultEntry.find(params[:id])
    end

    def vault_entry_params
      params.require(:vault_entry).permit!
    end
end
