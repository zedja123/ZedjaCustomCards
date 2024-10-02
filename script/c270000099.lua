--Albaz, the Fallen
local s,id=GetID()
function s.initial_effect(c)
	-- Fusion Material: 1 Code: 68468459 OR 1 Fusion Monster + 1+ monsters on the field
	c:EnableReviveLimit()
	Fusion.AddProcFunFunRep(c,s.matfilter1,Card.IsOnField,1,99,true)
	
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
end

-- Fusion Materials: Code 68468459 or 1 Fusion Monster + 1+ monsters on the field
function s.matfilter1(c,fc,sumtype,tp)
	return c:IsCode(68468459) or c:IsType(TYPE_FUSION,fc,sumtype,tp)
end

function s.ffilter2(c)
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
		return Duel.GetLocationCountFromEx(tp)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.spfilter(c,e,tp)
	return (c:IsCode(CARD_ALBAZ) or c:ListsCode(CARD_ALBAZ)) and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsType(TYPE_FUSION)
end

-- Operation: Special Summon the selected Fusion Monster
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCountFromEx(tp)<=0 then return end
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		g:GetFirst():CompleteProcedure() -- Treat as a Fusion Summon
	end
end
-------

-- Condition: If this card was sent to the GY this turn
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD+LOCATION_HAND) and e:GetHandler():IsReason(REASON_EFFECT+REASON_BATTLE)
end

-- Target: Send 1 Fusion Monster from Extra Deck to GY and add or Special Summon 1 specific monster
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil)
			and (Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil)
			or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- Filter: Fusion Monsters in the Extra Deck that mention "Fallen of Albaz" as material
function s.tgfilter(c)
	return c:IsType(TYPE_FUSION) and c:ListsCode(CARD_ALBAZ) and c:IsAbleToGrave()
end

-- Filter: Monsters in the Deck that either have code 68468459 or mention 68468459 in their text
function s.addfilter(c)
	return c:IsCode(68468459) or c:ListsCode(CARD_ALBAZ) and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(nil,0,tp,false,false))
end

-- Operation: Send Fusion Monster from Extra Deck to GY, then add or Special Summon the specified monster
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #tg>0 and Duel.SendtoGrave(tg,REASON_EFFECT)>0 then
		local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			local opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2)) -- Option to add or Special Summon
			if opt==0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			else
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end