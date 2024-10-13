--Albaz, the Fallen
--Scripted by Zedja
local s,id=GetID()
function s.initial_effect(c)
	-- Fusion Material: 1 Code: 68468459 OR 1 Fusion Monster + 1+ monsters on the field
	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,true,true,s.ffilter,1,99,s.matfilter1)
	
	-- Special Summon by tributing 1 Fusion Monster you control
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	e1:SetValue(SUMMON_TYPE_FUSION)
	c:RegisterEffect(e1)
	--Change name
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetValue(CARD_ALBAZ)
	c:RegisterEffect(e2)

	-- Tribute this card to Special Summon 1 Fusion Monster that mentions "Fallen of Albaz" as material
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)

	--Register the fact it was sent to GY
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
end

-- Fusion Materials: Code 68468459 or 1 Fusion Monster + 1+ monsters on the field
function s.matfilter1(c,fc,sumtype,tp)
	return c:IsCode(68468459) or c:IsType(TYPE_FUSION,fc,sumtype,tp)
end

function s.ffilter(c)
	return c:IsOnField()
end

-- Special Summon condition: Tribute 1 Fusion Monster you control
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and
		Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_MZONE,0,1,nil,TYPE_FUSION)
end

-- Operation: Tribute 1 Fusion Monster and Special Summon this card
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_MZONE,0,1,1,nil,TYPE_FUSION)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end

-- Cost: Tribute this card
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end

-- Target: Special Summon 1 Fusion Monster that mentions "Fallen of Albaz" as material from the Extra Deck
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCountFromEx(tp)>=0 -- Check for available location
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.spfilter(c,e,tp)
	return (c:IsCode(CARD_ALBAZ) or c:ListsCode(CARD_ALBAZ)) -- Check for "Fallen of Albaz"
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) -- Check if it can be special summoned
		and c:IsType(TYPE_FUSION) -- Ensure it is a Fusion monster
end

-- Operation: Special Summon the selected Fusion Monster
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
Debug.Message(Duel.GetLocationCountFromEx(tp))
	if Duel.GetLocationCountFromEx(tp)<=0 then return end -- Ensure there is an available location
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		g:GetFirst():CompleteProcedure() -- Treat as a Fusion Summon
	end
end

-------
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end

function s.thfilter(c,e,tp,ft)
	return c:IsMonster() and (c:ListsCode(CARD_ALBAZ) or c:IsCode(68468459))
		and (c:IsAbleToHand() or (c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0))
end
function s.tgfilter(c,e,tp,ft)
	return c:ListsCode(CARD_ALBAZ) and c:IsAbleToGraveAsCost() and c:IsType(TYPE_FUSION)
end
	--Activation legality
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil) -- Select the matching card
	if #tg>0 then
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft):GetFirst()
	if tc then
		aux.ToHandOrElse(tc,tp,function(c)
			return tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0 end,
		function(c)
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end,
		aux.Stringid(id,3))
	end
end