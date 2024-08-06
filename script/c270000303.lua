--Lavoisier Bertha
local s,id,o=GetID()
function c270000303.initial_effect(c)
		-- Pendulum Summon
	Pendulum.AddProcedure(c)
	-- Special Summon from Pendulum Zone
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	e1:SetCountLimit(1,{id,1})
	c:RegisterEffect(e1)
	-- Special Summon from Pendulum Zone when Link monster is summoned
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	e2:SetCountLimit(1,{id,2})
	c:RegisterEffect(e2)
	-- Place in Pendulum Zone when a "Lavoisier" Link monster is summoned
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.pzcon)
	e3:SetTarget(s.pztg)
	e3:SetOperation(s.pzop)
	e3:SetCountLimit(1,{id,3})
	c:RegisterEffect(e3)

	-- Add 1 "Lavoisier" Spell/Trap from Deck to hand when Summoned
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,4})
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
-- Shuffle and spsummon with = shuffled
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,{id,5})
	e6:SetCost(s.spcost3)
	e6:SetTarget(s.sptg3)
	e6:SetOperation(s.spop3)
	c:RegisterEffect(e6)
	-- Special Summon "Lavoisier" Pendulum Monster
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1, {id,6})
	e7:SetTarget(s.sptg2)
	e7:SetOperation(s.spop2)
	-- While a Link monster points to this card, that card gains the effect
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e8:SetRange(LOCATION_MZONE)
	e8:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e8:SetTarget(s.eftg)
	e8:SetLabelObject(e7)
	c:RegisterEffect(e8)
end
-- Pendulum Effects
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end

function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- Lock Extra Deck summons to "Lavoisier" monsters
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.extralimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.extralimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0xf13)
end

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_LINK) and eg:IsExists(Card.IsSetCard,1,nil,0xf13)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
end

function s.pzfilter(c,tp)
	return c:IsType(TYPE_LINK) and c:IsSetCard(0xf13) and c:IsControler(tp)
end

function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.pzfilter,1,nil,tp)
end

function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end

function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

--Monster effects

function s.eftg(e,c)
	return c:GetLinkedGroup():IsContains(e:GetHandler())
end

function s.thfilter(c)
	return c:IsSetCard(0xf13) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- Shuffle and spsummon with = shuffled

function s.shfilter(c)
	return c:IsSetCard(0xf13) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost() and c:IsFaceup()
end
function s.spfilter(c,e,tp,ct,g)
	return c:IsType(0xf13) and c:IsType(TYPE_LINK) and c:IsLink(ct)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
end
function s.spcost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.shfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil)
	local nums={}
	for i=1,#g do
		if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,i,g) then
			table.insert(nums,i)
		end
	end
	if chk==0 then return #nums>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local ct=Duel.AnnounceNumber(tp,table.unpack(nums))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local rg=g:Select(tp,ct,ct,nil)
	Duel.SendtoDeck(rg,tp,SEQ_DECKSHUFFLE,REASON_COST)
	e:SetLabel(ct)
end
function s.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end --existence of card to summon checked in cost
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop3(e,tp,eg,ep,ev,re,r,rp)
	--special Summon
	local ct=e:GetLabel()
	if not ct then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,ct)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.spfilter1(c,tp)
	return c:IsType(TYPE_LINK) and c:IsSetCard(0xf13) and c:IsControler(tp)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter1,1,nil,tp)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local zone=0
		for tc in aux.Next(eg) do
			if s.spfilter1(tc,tp) then
				zone=zone|tc:GetLinkedZone(tp)
			end
		end
		return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local zone=0
	for tc in aux.Next(eg) do
		if s.spfilter(tc,tp) then
			zone=zone|tc:GetLinkedZone(tp)
		end
	end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)>0 then
	end
end

function s.spfilter3(c,e,tp)
	return c:IsSetCard(0xf13) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,rp,nil,c)>0
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(s.spfilter3,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter3,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		local tc=g:GetFirst()
		-- Negate its effects
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
end