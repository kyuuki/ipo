class IpoCompaniesController < ApplicationController
  before_action :set_ipo_company, only: [:show, :edit, :update, :destroy]

  # GET /ipo_companies
  # GET /ipo_companies.json
  def index
    @ipo_companies = IpoCompany.all.order(listed_at: :desc).order(id: :desc)
  end

  # GET /ipo_companies/1
  # GET /ipo_companies/1.json
  def show
  end

  # GET /ipo_companies/new
  def new
    @ipo_company = IpoCompany.new
  end

  # GET /ipo_companies/1/edit
  def edit
  end

  # POST /ipo_companies
  # POST /ipo_companies.json
  def create
    @ipo_company = IpoCompany.new(ipo_company_params)

    respond_to do |format|
      if @ipo_company.save
        format.html { redirect_to @ipo_company, notice: 'Ipo company was successfully created.' }
        format.json { render :show, status: :created, location: @ipo_company }
      else
        format.html { render :new }
        format.json { render json: @ipo_company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ipo_companies/1
  # PATCH/PUT /ipo_companies/1.json
  def update
    respond_to do |format|
      if @ipo_company.update(ipo_company_params)
        format.html { redirect_to @ipo_company, notice: 'Ipo company was successfully updated.' }
        format.json { render :show, status: :ok, location: @ipo_company }
      else
        format.html { render :edit }
        format.json { render json: @ipo_company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ipo_companies/1
  # DELETE /ipo_companies/1.json
  def destroy
    @ipo_company.destroy
    respond_to do |format|
      format.html { redirect_to ipo_companies_url, notice: 'Ipo company was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ipo_company
      @ipo_company = IpoCompany.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ipo_company_params
      params.require(:ipo_company).permit(:code, :name, :rank, :price, :listed_at, :apply_from, :apply_to)
    end
end
